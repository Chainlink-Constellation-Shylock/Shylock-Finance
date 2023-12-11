"use client"

import React, { useState, useEffect } from 'react';
import QRCode from 'qrcode.react';

const QRCodeGenerator: React.FC = () => {
  const [qrData, setQrData] = useState<string | null>(null);
  const [newHostUrl, setNewHostUrl] = useState('');
  const [isQrVisible, setIsQrVisible] = useState(false);

  const base_url = 'http://localhost:3001/';

  const generateQR = () => {
    fetch(base_url + "api/sign-in")
      .then((response) => Promise.all([Promise.resolve(response.headers.get("x-id")), response.json()]))
      .then(([id, data]) => {
        console.log(data);
        setQrData(JSON.stringify(data));
        setIsQrVisible(true);
        return id;
      })
      .catch((error) => console.log(error));
  };

  const updateHostUrl = () => {
    if (!newHostUrl) {
      alert("Please enter a valid URL");
      return;
    }

    fetch(base_url + "api/update-host", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ hostUrl: newHostUrl }),
    })
      .then((response) => response.text())
      .then((data) => alert(data))
      .catch((error) => console.error("Error:", error));
  };

  return (
    <main className="main-content">
      <button 
        className="bg-[#755f44] border-2 border-[#755f44] mt-2 rounded-md text-white cursor-pointer font-semibold h-10 px-6 text-center transition duration-300 ease-out focus:outline-none w-30 hover:bg-[#766f44] hover:text-white hover:shadow-lg active:shadow-none" 
        onClick={generateQR}
      >
        Sign Up
      </button>
      <div className="ml-10 p-5 border-3 border-dashed rounded-lg h-50 w-50"> 
        <QRCode value={qrData ?? ''} size={150} />
      </div>
      <div className="flex bottom-5 w-1/2 flex item-start">
        <div className="inline-block">
          <input className="border-black h-10" type="text" value={newHostUrl} onChange={(e) => setNewHostUrl(e.target.value)} placeholder="  Enter new host URL" />
          <button 
            className='bg-[#755f44] border-2 border-[#755f44] mt-2 rounded-md text-white cursor-pointer font-semibold h-10 px-6 text-center transition duration-300 ease-out focus:outline-none w-30 hover:bg-[#766f44] hover:text-white hover:shadow-lg active:shadow-none'
            onClick={updateHostUrl}
          >
            Update Host URL
          </button>
        </div>
      </div>
    </main>
  );
};

export default QRCodeGenerator;
