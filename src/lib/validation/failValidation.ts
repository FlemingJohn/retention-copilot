import { ServiceError } from '@/lib/errors/ServiceError'

export function failValidation(message: string): never {
  throw new ServiceError(message, 400)
}
