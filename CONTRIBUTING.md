# Contributing to the gnomAD blog

Login to Netlify CMS at https://ourdna-dev.popgen.rocks/news/admin/. To make changes to the blog, you must have write access to the [ourdna-browser-blog GitHub repository](https://github.com/populationgenomics/ourdna-browser-blog)

## Adding a new post

1. Select the "Contents" tab and click the "New Post" button.

2. Set the post's title and publication date. Add authors and categories.

3. Write the body of the post using either the rich text editor or [Markdown](https://www.markdownguide.org/basic-syntax/).

   - Click the "Toggle preview" button at the top right to show a preview of the post.

   - To control what is shown "above the fold" in the list of posts on the home page, use Markdown mode to add a line containing an HTML comment:

      ```html
      <!-- end_excerpt -->
      ```

      Any content after that comment will only be visible by clicking the "Continue reading" link to view the full post.

4. Click the "Save" button to save a draft of the post. Saving a draft opens a pull request on the [gnomad-blog GitHub repository](https://github.com/populationgenomics/ourdna-browser-blog) GitHub with the new post. Further edits can be made in the CMS (the new post will appear in the Drafts column on the Workflow tab). This will add commits to the PR's branch. Alternatively, the branch can be edited on GitHub or pulled and edited locally.

   - When the PR is opened, a preview site containing its changes will automatically be deployed to `https://gnomad.broadinstitute.org/news/preview/<PR_NUMBER>`. This may take a few minutes. While it is building, a "Check for preview" button will appear in the top bar of the CMS next to the "Set status" and "Publish" buttons. Once the preview site is finished building, clicking that button will cause it to change to a "View Preview" link. To see progress generating the preview site, look at the PR's status checks on GitHub.

5. When the post is ready, click the "Publish" button in Netlify CMS. This merges the PR. Alternatively, the PR can be merged on GitHub. Changes committed to the `main` branch will automatically be deployed to `https://ourdna.populationgenomics.org.au/news/`.

## Images

Images uploaded through the CMS will be place in the [`static/images` directory](https://github.com/populationgenomics/ourdna-browser-blog/tree/main/static/images). Netlify CMS does not yet support folders in the media library, so images from all posts will be uploaded in the same directory. Thus, please use descriptive file names that reference the post the image belongs to. Alternatively, images can be organized in directories by adding them locally and pushing to GitHub. However, images added this way will not appear in the CMS's media library.

**To improve performance of the website, please [optimize images](https://web.dev/uses-optimized-images/) before uploading them.**

- Because of their display size on the blog, images should not be larger than 1200 pixels wide.
- JPEG may be much for efficient than PNG for some types of images.

When the site is built, the `images` folder is copied to the root directory of the site. Thus, a URL to an image from the CMS will look like `../images/file.png`.

There are multiple ways to add an image to a post:

- Media library

   Select Rich Text mode, click the Plus button, and select Image. Only images uploaded through the CMS or in `static/images` (not in a nested directory) can be selected this way.

- Markdown

   Select Markdown mode.

   ```md
   ![alt text](../images/file.png)
   ```

- HTML

   Works in either Rich Text or Markdown mode. Useful for adding captions.

   ```html
   <figure>
      <img alt="alt text" src="../images/file.png" />
      <figcaption>Caption text</figcaption>
   </figure>
   ```

## Videos

To add a video, place the file in the `static/images` directory and add the following HTML:

```html
<figure>
   <video src="../images/file.mp4" type="video/mp4" controls autoplay loop />
</figure>
```

To reduce the file size of videos produced by screen recording, use [ffmpeg](https://ffmpeg.org/) ([available through Homebrew](https://formulae.brew.sh/formula/ffmpeg)).

```shell
ffmpeg -i input.mov \
   -vcodec h264 \ # Convert to MP4
   -an \ # Drop audio
   -filter_complex "scale=iw*min(1\,1200/iw):-1" \ # Resize to a max width of 1200px
   output.mp4
```

## Linking to other posts

To link to another post, the link URL is based on the name of the post's source file. For example, to link to the post for `2021-10-linking-example.md`, the link would be `[link text](/2021-10-linking-example/)`.

Linking to sections within a page can be done by linking to the section heading's anchor. The anchor ID is the section heading in all lower case with spaces replaced by dashes.

For example, to link to a section with heading `### An example section of a gnomAD blog post` in `2021-10-linking-example.md`, the link would be `[link text](/2021-10-linking-example/#an-example-section-of-a-gnomad-blog-post)`. For links to a section on the same page as the link (for example, a table of contents at the beginning of a page) the URL path can be omitted (for example, `[link text](#an-example-section-of-a-gnomad-blog-post)`).

## Footnotes

See https://www.markdownguide.org/extended-syntax/#footnotes.
