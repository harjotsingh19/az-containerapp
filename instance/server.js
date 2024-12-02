const express = require('express');
const path = require('path');
const fs = require('fs');
const archiver = require('archiver');

const app = express();
const port = 7005;

// Base directory for file access
const fileDirectory = path.join(__dirname);

// Helper function to sanitize the file path
const sanitizeFilePath = (filePath) => {
  const fullPath = path.resolve(fileDirectory, filePath);
  if (fullPath.startsWith(fileDirectory)) {
    return fullPath;
  } else {
    throw new Error('Invalid file path');
  }
};

app.get('/download', (req, res) => {
  const filePathParam = req.query.filePath;
  if (!filePathParam) {
    return res.status(400).send('File path is required');
  }

  // Replace $HOME with the server's home directory
  const homeDirectory = process.env.HOME || process.env.USERPROFILE;
  const fullFilePath = filePathParam.replace('$HOME', homeDirectory);
  console.log("🚀 ~ Full file path:", fullFilePath);

  fs.stat(fullFilePath, (err, stats) => {
    if (err) {
      if (err.code === 'ENOENT') {
        return res.status(404).send(`File not found: ${fullFilePath}`);
      }
      console.error("Error accessing path:", err);
      return res.status(500).send('An error occurred while accessing the path.');
    }

    if (stats.isDirectory()) {
      // Handle directory: zip and send it
      const archive = archiver('zip', { zlib: { level: 9 } });
      res.attachment('folder.zip'); // Specify the name of the zip file

      archive.on('error', (err) => {
        console.error("Error zipping directory:", err);
        if (!res.headersSent) {
          res.status(500).send('Error compressing the directory');
        }
      });

      archive.pipe(res);
      archive.directory(fullFilePath, false);
      archive.finalize().catch((err) => {
        console.error("Error finalizing archive:", err);
      });

    } else if (stats.isFile()) {
      // Handle file: send it directly
      const stream = fs.createReadStream(fullFilePath);

      stream.on('error', (err) => {
        console.error("Error reading file:", err);
        if (!res.headersSent) {
          res.status(500).send('Error downloading the file');
        }
      });

      res.on('close', () => {
        console.log("Client disconnected during file download.");
      });

      stream.pipe(res).on('finish', () => {
        console.log("File sent successfully:", fullFilePath);
      });

    } else {
      return res.status(400).send('The provided path is neither a file nor a directory.');
    }
  });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
