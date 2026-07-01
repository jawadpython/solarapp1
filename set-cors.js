/**
 * Script to set CORS configuration for Firebase Storage
 * Run with: node set-cors.js
 */

const { Storage } = require('@google-cloud/storage');

const bucketName = 'tawfir-energy-prod-98053.firebasestorage.app';

const corsConfiguration = [
  {
    origin: ['*'],
    method: ['GET', 'HEAD', 'PUT', 'POST', 'DELETE'],
    maxAgeSeconds: 3600,
    responseHeader: ['Content-Type', 'Content-Length', 'Content-Disposition', 'Access-Control-Allow-Origin']
  }
];

async function setCors() {
  try {
    const storage = new Storage();
    await storage.bucket(bucketName).setCorsConfiguration(corsConfiguration);
    console.log(`✅ CORS configuration set successfully for ${bucketName}`);
    console.log('CORS config:', JSON.stringify(corsConfiguration, null, 2));
  } catch (error) {
    console.error('❌ Error setting CORS:', error.message);
    console.log('\nTry these alternatives:');
    console.log('1. Go to: https://console.cloud.google.com/storage/browser/' + bucketName);
    console.log('2. Click "Edit bucket" > "Cross-origin resource sharing (CORS)"');
    console.log('3. Add this config:');
    console.log(JSON.stringify(corsConfiguration, null, 2));
  }
}

setCors();
