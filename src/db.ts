import mysql from 'mysql2/promise';

export class Database {
  private connection: mysql.Connection | null = null;

  async connect() {
    try {
      this.connection = await mysql.createConnection({
        host: 'db-dev-vpc.c0sj7nuy87vh.us-east-1.rds.amazonaws.com',
        user: 'lf',
        password: 'SubZ3r00',
        database: 'lotusflare_zerorating'
      });
      console.log('Successfully connected to the database.');
    } catch (error) {
      console.error('Error connecting to the database:', error);
      throw error;
    }
  }

  async query(sql: string, params?: any[]) {
    if (!this.connection) {
      throw new Error('Database not connected. Call connect() first.');
    }
    try {
      const [results] = await this.connection.execute(sql, params);
      return results;
    } catch (error) {
      console.error('Error executing query:', error);
      throw error;
    }
  }

  async disconnect() {
    if (this.connection) {
      await this.connection.end();
      this.connection = null;
      console.log('Database connection closed.');
    }
  }
} 