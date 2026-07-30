import { CallableRequest, HttpsError } from 'firebase-functions/v2/https';

export type Role = 'admin' | 'supplier';

export function requireAdmin(request: CallableRequest<any>) {
  if (!request.auth || request.auth.token.role !== 'admin') {
    throw new HttpsError('permission-denied', 'This action requires an admin account.');
  }
}

export function requireSupplier(request: CallableRequest<any>) {
  if (!request.auth || request.auth.token.role !== 'supplier') {
    throw new HttpsError('permission-denied', 'This action requires a supplier account.');
  }
}
