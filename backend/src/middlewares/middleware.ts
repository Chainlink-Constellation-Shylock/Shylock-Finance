import { Request, Response, NextFunction } from 'express';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
    if (err.message === 'Duplicate entry detected') {
        return res.status(400).json({ error: err.message });
    }
    console.error(err.stack);
    return res.status(500).json({ error: 'Internal Server Error' });
};