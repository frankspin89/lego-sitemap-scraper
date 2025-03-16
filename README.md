# LEGO Sitemap Scraper Workflow

This repository contains an n8n workflow for scraping LEGO product URLs from the LEGO.com sitemaps and storing them in a Supabase database.

## Overview

The workflow performs the following steps:

1. Fetches the Dutch and English LEGO product sitemaps
2. Retrieves existing products from the Supabase database to avoid duplicates
3. Processes the sitemap XML to extract product URLs and IDs
4. Compares the sitemap data with existing database records
5. Creates new entries for products that don't exist in the database
6. Stores the new records in the `lego_url_set_scrape` Supabase table

## Key Updates

The workflow has been updated to match the `lego_url_set_scrape` table schema with the following fields:

- `id` (int4, primary key)
- `product_id` (text)
- `dutch_url` (text)
- `english_url` (text)
- `status` (text)
- `worker_id` (text)
- `processing_started_at` (timestamptz)
- `created_at` (timestamptz)
- `updated_at` (timestamptz)
- `dutch_markdown` (text)
- `dutch_html` (text)
- `dutch_metadata` (jsonb)
- `dutch_success` (bool)
- `english_markdown` (text)
- `english_html` (text)
- `english_metadata` (jsonb)
- `english_success` (bool)

## Technical Details

The main changes in the workflow are:

1. Updated table name from `lego_url_pairs` to `lego_url_set_scrape`
2. Added additional fields to the data structure when creating new records:
   - worker_id
   - processing_started_at
   - dutch_markdown, dutch_html, dutch_metadata, dutch_success
   - english_markdown, english_html, english_metadata, english_success

## Scheduling

The workflow is scheduled to run every 12 hours, triggering at 14 minutes past the hour.

## Usage

1. Import the workflow JSON into your n8n instance
2. Configure your Supabase credentials
3. Activate the workflow to start collecting LEGO product URLs

## Data Flow

1. Schedule Trigger activates the workflow
2. HTTP Requests fetch the Dutch and English sitemaps
3. Supabase node retrieves existing products
4. Code nodes process the data and extract relevant information
5. New products are identified and stored in the database
6. Summary statistics are generated at completion

## License

MIT
