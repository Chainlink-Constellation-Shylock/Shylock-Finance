import express, {Request, Response} from 'express';
import {
    querySnapshotPoints,
    queryUniswapPoints,
    makeRequestForSnapshotFuji,
    makeRequestForUniswapFuji
} from '../chainlink_functions';

const router = express.Router();

router.get('/:dao/:username', async (req: Request, res: Response, next) => {
    try {
        const dao = req.params.dao;
        const userAddr  = req.params.username;
        const snapShotPoint = await querySnapshotPoints(dao, userAddr);
        console.log(snapShotPoint);
        const uniswapPoint = await queryUniswapPoints(userAddr);
        console.log(uniswapPoint);
        if (snapShotPoint === undefined || uniswapPoint === undefined) {
            return res.status(400).send('No data');
        }
        const userPointString = parseInt(snapShotPoint.toString());
        const uniswapPointString = parseInt(uniswapPoint.toString());

        res.status(200).json(
            {
                "snapshot": userPointString,
                "uniswap": uniswapPointString,
            }
        );

        try {
            await makeRequestForSnapshotFuji(dao, userAddr);
            console.log("Request for snapshot point sent");
            await makeRequestForUniswapFuji(userAddr);
            console.log("Request for uniswap point sent");
        } catch (innerError) {
            console.error('Error making external requests:', innerError);
        }
    } catch (error) {
        console.error(error);
        next(error);
    }
});

export default router;
