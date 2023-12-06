import express, {Request, Response} from 'express';
import {querySnapshotPoints, queryUniswapPoints} from '../chainlink_functions';

const router = express.Router();

router.get('/:dao/:username', async (req: Request, res: Response, next) => {
    try {
        const dao = req.params.dao;
        const userAddr  = req.params.username;
        const userPoint = await querySnapshotPoints(dao, userAddr);
        console.log(userPoint);

        const userPointString = userPoint?.toString();
        if (userPointString) {
            return res.status(200).json({userPoint: userPointString});
        }
        return res.status(200);
    } catch (error) {
        console.error(error);
        next(error);
    }
});

export default router;
