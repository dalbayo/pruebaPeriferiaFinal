import { HttpClient } from '@angular/common/http';
import { Injectable, signal } from '@angular/core';
import { Observable, tap } from 'rxjs';
import { construirBaseUrl } from '../shared/construir-base-url';
import { LoginRequest, LoginResponse } from '../models/auth.model';

const STORAGE_KEYS = {
  accessToken: 'accessToken',
  refreshToken: 'refreshToken',
  username: 'username',
};

@Injectable({
  providedIn: 'root',
})
export class AuthApiService {
  private readonly baseUrl = construirBaseUrl('/api/v1/api/auth');

  private usernameSignal = signal<string | null>(
    localStorage.getItem(STORAGE_KEYS.username),
  );
  private isLoggedInSignal = signal<boolean>(
    !!localStorage.getItem(STORAGE_KEYS.accessToken),
  );

  constructor(private http: HttpClient) {}

  getUsername() {
    return this.usernameSignal;
  }

  IsLoggedIn() {
    return this.isLoggedInSignal;
  }

  getAccessToken(): string | null {
    return localStorage.getItem(STORAGE_KEYS.accessToken);
  }

  login(username: string, password: string): Observable<LoginResponse> {
    const body: LoginRequest = { username, password };
    return this.http
      .post<LoginResponse>(`${this.baseUrl}/login`, body)
      .pipe(tap((tokens) => this.persistSession(username, tokens)));
  }

  // TODO: confirmar con backend el path real de registro (se asume /auth/register)
  register(username: string, password: string): Observable<LoginResponse> {
    const body: LoginRequest = { username, password };
    return this.http.post<LoginResponse>(`${this.baseUrl}/register`, body);
  }

  // TODO: confirmar con backend el path real de recuperacion de contrasena (se asume /auth/forgot-password)
  forgotPassword(username: string): Observable<void> {
    return this.http.post<void>(`${this.baseUrl}/forgot-password`, {
      username,
    });
  }

  logout(): void {
    localStorage.removeItem(STORAGE_KEYS.accessToken);
    localStorage.removeItem(STORAGE_KEYS.refreshToken);
    localStorage.removeItem(STORAGE_KEYS.username);
    this.usernameSignal.set(null);
    this.isLoggedInSignal.set(false);
  }

  private persistSession(username: string, tokens: LoginResponse): void {
    localStorage.setItem(STORAGE_KEYS.accessToken, tokens.accessToken);
    localStorage.setItem(STORAGE_KEYS.refreshToken, tokens.refreshToken);
    localStorage.setItem(STORAGE_KEYS.username, username);
    this.usernameSignal.set(username);
    this.isLoggedInSignal.set(true);
  }
}
