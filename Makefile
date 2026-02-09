.PHONY: serve build clean draft new stop

# Run Hugo dev server with live reload
serve:
	hugo server -D --bind 0.0.0.0 --port 1313

# Run Hugo dev server (published posts only, no drafts)
serve-prod:
	hugo server --bind 0.0.0.0 --port 1313

# Build the site for production
build:
	hugo --minify

# Build including draft posts
build-draft:
	hugo -D --minify

# Remove generated files
clean:
	rm -rf public/ resources/

# Create a new post (usage: make new POST=my-new-post)
new:
	hugo new posts/$(POST).md

# Check Hugo version
version:
	hugo version

# Full rebuild: clean + build
rebuild: clean build
