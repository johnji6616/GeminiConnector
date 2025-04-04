import { GoogleGenerativeAI } from '@google/generative-ai';
import { DocumentQAConfig, QARequest } from './types';
import * as fs from 'fs';
import * as path from 'path';

export class DocumentQA {
  private model: any;
  private config: DocumentQAConfig;

  constructor(config: DocumentQAConfig) {
    this.config = config;
    const genAI = new GoogleGenerativeAI(config.apiKey);
    this.model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash',
      generationConfig: {
        temperature: this.config.temperature ?? 0.7,
        maxOutputTokens: this.config.maxOutputTokens ?? 2048,
      }
    });
  }

  async loadFileContent(filePath: string): Promise<string> {
    try {
      const absolutePath = path.resolve(filePath);
      return fs.readFileSync(absolutePath, 'utf-8');
    } catch (error) {
      console.error('Error reading file:', error);
      throw error;
    }
  }

  async getAnswer(request: QARequest): Promise<string> {
    try {
      const prompt = `
        Context: ${request.context}
        
        Question: ${request.question}
      `;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      console.log(response.text());
      return response.text();
    } catch (error) {
      console.error('Error getting answer from Gemini:', error);
      throw error;
    }
  }
} 