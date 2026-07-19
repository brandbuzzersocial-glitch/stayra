#!/bin/bash
# scripts/audit-urls.sh
# Audits all external asset/image URLs in blog-data.ts to make sure they return 200 OK.

set -e

echo "=== Starting SEO Audit: External Image & Asset URLs ==="

# Extract all http/https URLs from src/data/blog-data.ts
urls=$(grep -o 'https://[^"]*' src/data/blog-data.ts | sed 's/\\//g' | sort -u)

if [ -z "$urls" ]; then
    echo "No external URLs found in src/data/blog-data.ts."
    exit 0
fi

failed=0
count=0

for url in $urls; do
    # Remove trailing query params or punctuation if needed (the regex keeps everything up to ")
    count=$((count+1))
    echo -n "[$count] Auditing: $url ... "

    # Run curl to get the HTTP status code
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "FAILED")

    if [ "$status" = "200" ]; then
        echo -e "\033[0;32m[200 OK]\033[0m"
    else
        echo -e "\033[0;31m[FAILED - Status: $status]\033[0m"
        failed=$((failed+1))
    fi
done

echo "=== SEO URL Audit Complete ==="
echo "Total URLs audited: $count"
if [ "$failed" -gt 0 ]; then
    echo -e "\033[0;31mWarning: $failed URLs failed the audit!\033[0m"
    exit 1
else
    echo -e "\033[0;32mAll URLs are 100% healthy and indexable!\033[0m"
    exit 0
fi
