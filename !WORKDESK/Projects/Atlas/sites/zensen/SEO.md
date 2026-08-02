# SEO launch checklist

SEO means helping search engines crawl, understand, and safely display the site. It does not guarantee ranking.

- Use one unique `<title>` and one useful meta description per indexable page.
- Use one visible `<h1>` that states the page's primary subject.
- Use logical heading order (`h2`, then `h3`) and real links with descriptive text.
- Add an absolute canonical URL when the public domain is known.
- Add `robots.txt` and `sitemap.xml` after the public URL exists.
- Remove `noindex` only when the page is intentionally public.
- Add image `alt` text; mark decorative images empty (`alt=""`).
- Test the mobile layout, 404 page, redirects, HTTPS, and broken links.
- Add JSON-LD only for facts visibly supported by the page.
- Keep a copy of the final deployed version for rollback.

Current known issue: the working page contains `noindex, nofollow`, which is appropriate for private staging but must be reviewed before public launch.
