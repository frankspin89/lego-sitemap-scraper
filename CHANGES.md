# Detailed Changes Made to the Workflow

This document outlines the specific changes made to update the workflow from using the original `lego_url_pairs` table to the new `lego_url_set_scrape` table schema.

## Table Name Changes

The database table name was updated from `lego_url_pairs` to `lego_url_set_scrape` in the following nodes:

1. In the "Get Existing Products" node:
```json
"parameters": {
  "operation": "getAll",
  "tableId": "lego_url_set_scrape", /* Changed from lego_url_pairs */
  "returnAll": true,
  "filterType": "none"
}
```

2. In the "Store in Supabase" node:
```json
"parameters": {
  "tableId": "lego_url_set_scrape", /* Changed from lego_url_pairs */
  "dataToSend": "autoMapInputData"
}
```

## Data Structure Changes

The main update was in the "Process All Data" node, where the data structure for new records was expanded to include all the fields from the new schema:

```javascript
// Original structure
newPairs.push({
  product_id: productId,
  dutch_url: dutchUrls[productId],
  english_url: englishUrls[productId],
  status: "pending",
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
});

// Updated structure
newPairs.push({
  product_id: productId,
  dutch_url: dutchUrls[productId],
  english_url: englishUrls[productId],
  status: "pending",
  worker_id: null, // New field
  processing_started_at: null, // New field
  created_at: now,
  updated_at: now,
  dutch_markdown: null, // New field
  dutch_html: null, // New field
  dutch_metadata: null, // New field
  dutch_success: null, // New field
  english_markdown: null, // New field
  english_html: null, // New field
  english_metadata: null, // New field
  english_success: null // New field
});
```

## Field Explanations

The added fields serve the following purposes:

1. **worker_id** (text): Identifies which worker process is handling this record
2. **processing_started_at** (timestamptz): Timestamp when processing of this record began
3. **dutch_markdown** (text): Markdown content extracted from the Dutch product page
4. **dutch_html** (text): HTML content extracted from the Dutch product page
5. **dutch_metadata** (jsonb): Structured data extracted from the Dutch product page
6. **dutch_success** (bool): Flag indicating if Dutch content extraction was successful
7. **english_markdown** (text): Markdown content extracted from the English product page
8. **english_html** (text): HTML content extracted from the English product page
9. **english_metadata** (jsonb): Structured data extracted from the English product page
10. **english_success** (bool): Flag indicating if English content extraction was successful

## Default Values

All new fields are initialized with `null` values when new records are created. This is because:

1. The scraping workflow initially only collects URLs
2. The actual content extraction happens in a separate process that will update these fields
3. The `worker_id` and `processing_started_at` will be set when a worker picks up the record for processing
4. The content and success fields will be populated after the extraction process is complete

## No Changes to Workflow Logic

The core workflow logic remains unchanged:
1. Fetch sitemaps
2. Extract URLs
3. Check for existing records
4. Insert new records
5. Generate summary statistics

Only the data structure and table name have been updated to match the new schema.
