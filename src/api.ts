import express, { Request, Response } from 'express';
import { DocumentQA } from './document_qa';
import { Database } from './db';
import { DocumentQAConfig, QARequest } from './types';
import { config } from 'dotenv';

const app = express();
app.use(express.json());

config();

// Initialize DocumentQA and Database instances
const qaConfig: DocumentQAConfig = {
  apiKey: process.env.GOOGLE_API_KEY!,
  temperature: 0.7,
};

const documentQA = new DocumentQA(qaConfig);
const db = new Database();

function extractSQL(response: string): string | null {
  // Split the response into lines
  const lines = response.split('\n')
    // Remove lines that start with backticks
    .filter(line => !line.trim().startsWith('`'))
    // Remove empty lines
    .filter(line => line.trim().length > 0);
  
  const cleanedResponse = lines.join('\n').trim();
  
  // Basic SQL validation
  const sqlKeywords = {
    required: ['SELECT', 'FROM'],
    optional: ['WHERE', 'JOIN', 'GROUP BY', 'ORDER BY', 'HAVING', 'INSERT', 'UPDATE', 'DELETE', 'UNION', 'INTERSECT', 'EXCEPT'],
    clauses: ['AND', 'OR', 'IN', 'NOT', 'LIKE', 'IS', 'NULL', 'ASC', 'DESC', 'LIMIT', 'OFFSET']
  };

  const upperResponse = cleanedResponse.toUpperCase();


  // Check for basic SQL syntax
  const hasValidSyntax = (
    // Must have at least one column selection
    upperResponse.includes('SELECT') &&
    // Must have a table reference
    upperResponse.includes('FROM')
  );

  // Return the SQL if it passes all checks
  return hasValidSyntax 
    ? cleanedResponse 
    : null;
}

interface QueryRequest {
  question: string;
  context?: string;
}

// Endpoint to query the database using natural language
app.post('/api/query', async (req: Request<{}, {}, QueryRequest>, res: Response) => {
  const { question, context } = req.body;

  if (!question) {
    return res.status(400).json({ error: 'Question is required' });
  }

  try {
    // Connect to the database
    await db.connect();

    // Load both the SQL schema file and Context file
    const schemaContent = await documentQA.loadFileContent('schema.sql');
    const contextContent = await documentQA.loadFileContent('Context.txt');
    
    // Combine schema with both contexts
    const combinedContext = `
      Database Schema:
      ${schemaContent}
      
      API Context Information:
      ${contextContent}
      
      ${context ? `Additional Context:\n${context}` : ''}
    `;

    const request: QARequest = {
      context: combinedContext,
      question: question + ". for you output, just return the runnalbe sql query nothing else",
    };

    // Get answer from Gemini
    const answer = await documentQA.getAnswer(request);
    
    // Extract SQL if present
    const sqlQuery = extractSQL(answer);

    if (sqlQuery) {
      // Execute the generated SQL query
      const results = await db.query(sqlQuery);

      // Create a new request to Gemini to interpret the results
      const interpretationRequest: QARequest = {
        context: `
          Database Schema:
          ${schemaContent}
          
          API Context Information:
          ${contextContent}
          
          The user asked: "${question}"
          The query returned the following results: ${JSON.stringify(results)}
          
          Please provide a clear, human-readable interpretation of these results, taking into account the database schema and API context provided above.
        `,
        question: "Please interpret these database results in a clear, human-readable format."
      };

      // Get human-readable interpretation from Gemini
      const interpretation = await documentQA.getAnswer(interpretationRequest);

      // Return everything
      res.json({
        question,
        answer: interpretation
      });
    } else {
      // If no SQL found, return the Gemini answer directly
      res.json({
        question,
        answer: answer
      });
    }

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  } finally {
    // Always disconnect from the database
    await db.disconnect();
  }
});

// Health check endpoint
app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok' });
});

const PORT = Number(process.env.PORT) || 3000;
const HOST = '0.0.0.0';  // Listen on all network interfaces

app.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
}); 