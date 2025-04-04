import { config } from 'dotenv';
import { DocumentQA } from './document_qa';
import { DocumentQAConfig, QARequest } from './types';
import { Database } from './db';
import * as path from 'path';

// Load environment variables
config();

function extractSQL(response: string): string {
  // Split the response into lines
  const lines = response.split('\n');
  
  // Remove first and last lines if they exist
  if (lines.length > 2) {
    return lines.slice(1, -1).join('\n').trim();
  }
  
  // If there are 2 or fewer lines, return the original response
  return response.trim();
}

async function main() {
  const qaConfig: DocumentQAConfig = {
    apiKey: process.env.GOOGLE_API_KEY!,
    temperature: 0.7,
  };

  const documentQA = new DocumentQA(qaConfig);
  const db = new Database();

  try {
    // Connect to the database
    await db.connect();

    // Load both the SQL schema file and Context file
    const schemaContent = await documentQA.loadFileContent('schema.sql');
    const contextContent = await documentQA.loadFileContent('Context.txt');

    // Combine both contents for the context
    const combinedContext = `
      Database Schema:
      ${schemaContent}
      
      API Context Information:
      ${contextContent}
    `;

    // Example questions about the schema and context
    const questions = [
      "give me user who change permissions for a role in the last 24 hours. for you output, just return the runnalbe sql query nothing else"
    ];

    // Ask each question
    for (const question of questions) {
      const request: QARequest = {
        context: combinedContext,
        question: question,
      };

      const answer = await documentQA.getAnswer(request);
      console.log('\nQuestion:', question);
      console.log('Full Response:', answer);
      
      // Extract just the SQL query
      const sqlQuery = extractSQL(answer);
      console.log('Extracted SQL:', sqlQuery);

      // Execute the generated SQL query
      try {
        const results = await db.query(sqlQuery);
        console.log('Query Results:', results);
      } catch (error) {
        console.error('Error executing query:', error);
      }
      console.log('----------------------------------------');
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    // Always disconnect from the database
    await db.disconnect();
  }
}

main(); 