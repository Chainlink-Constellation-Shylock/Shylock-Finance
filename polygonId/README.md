# Polygon ID KYC

## How to use

### KYC DID Issuance

1. Go to [polygon id issuer UI](https://user-ui:password-ui@issuer-ui.polygonid.me/schemas).
2. Click on `Import Schema` button.
3. Copy and paste this url of [json schema](https://raw.githubusercontent.com/Chainlink-Constellation-Shylock/Shylock-Finance/main/polygonId/credential_schemas/ShylockKYC/ShylockKYC.json).
4. Click the `Issue` button on what you've just imported.
5. Fill out the form and click the `Issue` button. (You should check gotKYC as `true`.)
6. Fire up your polygon id application on your phone and scan the QR code.
7. Now the DID is on your phone. (If not, please scan once more.)

![KYC DID](../assets/did_KYC.jpeg)

### KYC DID Verification

1. Go to this [verification page](). This page checks if the DID is valid and if the user has a KYC.
2. Connect wallet of your preference and scan the QR code.
   ![DID QR Code](../assets/did_qr.png)
3. The server will check if the DID is valid and if the user has a KYC.
   ![KYC DID Verification](../assets/did_verification.png)

4. If the user has a KYC, the server will send a transaction to the governance contract deployed on Avalanche C-Chain (Fuji Testnet).

   ```json
   {
   id: 'd0b6567a-9551-4fcf-aa8e-b10a5985cb8a',
   typ: 'application/iden3-zkp-json',
   type: 'https://iden3-communication.io/authorization/1.0/response',
   thid: '7f38a193-0918-4a48-9fac-36adfdb8b542',
   body: {
    did_doc: {
      context: [Array],
      id: 'did:polygonid:polygon:mumbai:2qNeb8RkFTZceF8MQCHxy2xsVDsmHPn82T8iALhcBF',
      service: [Array]
    },
    message: '',
    scope: [ [Object] ]
   },
   from: 'did:polygonid:polygon:mumbai:2qNeb8RkFTZceF8MQCHxy2xsVDsmHPn82T8iALhcBF',
   to: 'did:polygonid:polygon:mumbai:2qDyy1kEo2AYcP3RT4XGea7BtxsY285szg6yP9SPrs'
   }
   ```

5. Then the user is verified and can use the Shylock Finance!
