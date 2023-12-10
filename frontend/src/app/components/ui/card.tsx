import React from 'react';

type CardProps = {
  className?: string;
  children: React.ReactNode;
};

export const Card: React.FC<CardProps> = ({ className, children }) => {
  return (
    <div className={`rounded-lg shadow-md ${className}`}>
      {children}
    </div>
  );
};

type CardHeaderProps = {
  className?: string;
  children: React.ReactNode;
};

export const CardHeader: React.FC<CardHeaderProps> = ({ className, children }) => {
  return (
    <div className={`pb-2 border-b-2 border-[#755f44] ${className}`}>
      {children}
    </div>
  );
};

type CardContentProps = {
  className?: string;
  children: React.ReactNode;
};

export const CardContent: React.FC<CardContentProps> = ({ className, children }) => {
  return (
    <div className={className}>
      {children}
    </div>
  );
};