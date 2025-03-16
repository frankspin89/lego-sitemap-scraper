# LEGO Crawler Workflow

This document explains the LEGO crawler workflow, which is responsible for processing the URLs collected by the sitemap scraper and extracting content from the LEGO product pages.

## Overview

The crawler workflow performs the following steps:

1. Claims pending URLs from the `lego_url_set_scrape` table
2. Determines which language versions (Dutch/English) need processing
3. Sends requests to a scraping service to fetch and process the HTML content
4. Updates the database with the extracted content

## Key Components

### 1. Database Table Structure

The crawler uses the `lego_url_set_scrape` table with the following key fields:

- `id`: Primary key
- `product_id`: LEGO product identifier
- `dutch_url`/`english_url`: URLs to scrape
- `status`: Current status (pending, processing, completed)
- `worker_id`: ID of the worker processing this record
- `processing_started_at`: When processing began
- `dutch_html`/`english_html`: Extracted HTML content
- `dutch_markdown`/`english_markdown`: Converted markdown content
- `dutch_metadata`/`english_metadata`: Extracted metadata
- `dutch_success`/`english_success`: Success flags

### 2. Claim Function

A PostgreSQL function `claim_pending_urls_set` is used to atomically claim URLs for processing:

```sql
CREATE OR REPLACE FUNCTION public.claim_pending_urls_set(
  worker_id text,
  batch_size integer DEFAULT 1
)
RETURNS SETOF public.lego_url_set_scrape
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  WITH selected_urls AS (
    SELECT id
    FROM public.lego_url_set_scrape
    WHERE status = 'pending'
    AND worker_id IS NULL
    AND (dutch_success IS NULL OR english_success IS NULL)
    LIMIT batch_size
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.lego_url_set_scrape u
  SET 
    worker_id = claim_pending_urls_set.worker_id,
    processing_started_at = NOW(),
    status = 'processing'
  FROM selected_urls
  WHERE u.id = selected_urls.id
  RETURNING u.*;
END;
$function$;
```

### 3. Workflow Steps

1. **Schedule Trigger**: Initiates the workflow at regular intervals
2. **Set Worker Config**: Configures worker ID and batch size
3. **Prepare for Claim**: Prepares parameters for claiming URLs
4. **Claim Pending URL**: Calls the `claim_pending_urls_set` function
5. **Generate Language Items**: Determines which language versions need processing
6. **HTTP Request FIRE**: Sends requests to the scraping service
7. **Prepare Success Data**: Formats the scraped data
8. **Update Record**: Updates the database with the results

## Configuration

The workflow is configured with:

- Worker ID: `crawl-worker-3`
- Batch size: 1 (processes one URL at a time)
- Timeout: 180 seconds for scraping requests
- Retry policy: 3 attempts with 5 second intervals

## Troubleshooting

If the crawler is not finding any URLs to process, check:

1. **Database Connection**: Ensure the Supabase connection is properly configured
2. **Table Name**: Verify the table name is correct (`lego_url_set_scrape`)
3. **Pending Records**: Check if there are records with `status = 'pending'`
4. **SQL Function**: Confirm the `claim_pending_urls_set` function is installed

## Implementation Notes

- The crawler processes both Dutch and English versions of each product page
- Each language is processed separately to allow for independent success/failure
- The workflow updates the success flags and metadata separately for each language
