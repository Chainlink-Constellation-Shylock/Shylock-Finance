import express, {Request, Response} from 'express';
import * as Functions from '../chainlink_functions/runFunctions';

const router = express.Router();

router.get('/:dao/:username', async (req: Request, res: Response, next) => {
    try {
        const dao = req.params.dao;
        const userAddr  = req.params.username;
        const userPoint = await Functions.queryUserPoints(dao, userAddr);
        res.json(userPoint);
    } catch (error) {
        console.error(error);
        next(error);
    }
});

export default router;
