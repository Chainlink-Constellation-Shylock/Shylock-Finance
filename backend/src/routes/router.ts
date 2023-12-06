import express, {Request, Response} from 'express';
import { querySnapshotPoints, queryUniswapPoints} from '../chainlink_functions';

const router = express.Router();

router.get('/:dao/:username', async (req: Request, res: Response, next) => {
    try {
        const dao = req.params.dao;
        const userAddr  = req.params.username;
        const snapShotPoint = await querySnapshotPoints(dao, userAddr);
        console.log(snapShotPoint);
        const uniswapPoint = await queryUniswapPoints(userAddr);
        console.log(uniswapPoint);
        // const userPointString = snapShotPoint?.toString();

        return res.status(200);
    } catch (error) {
        console.error(error);
        next(error);
    }
});

export default router;
