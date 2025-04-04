export interface DocumentQAConfig {
  apiKey: string;
  temperature?: number;
  maxOutputTokens?: number;
}

export interface QARequest {
  context: string;
  question: string;
} 