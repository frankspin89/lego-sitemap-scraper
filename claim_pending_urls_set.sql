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

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.claim_pending_urls_set(text, integer) TO authenticated;
