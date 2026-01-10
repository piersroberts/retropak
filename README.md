# retropak

## Documentation

This repository includes MkDocs-based documentation that can be built and deployed to Cloudflare Pages.

### Installing MkDocs

To work with the documentation locally, you need to install MkDocs:

```bash
pip install mkdocs
```

### Building the Documentation

To build the static documentation site:

```bash
mkdocs build
```

This will generate the static site in the `site/` directory.

### Local Development Server

To preview the documentation locally with live reloading:

```bash
mkdocs serve
```

Then visit `http://127.0.0.1:8000/` in your browser.

### Deploying to Cloudflare Pages

To deploy the documentation to Cloudflare Pages:

1. Connect your repository to Cloudflare Pages
2. Set the **Build command** to: `pip install mkdocs && mkdocs build`
3. Set the **Build output directory** to: `site/`

Cloudflare Pages will automatically build and deploy your documentation on every push.