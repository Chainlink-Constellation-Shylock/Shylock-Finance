import React from 'react';


type TabsProps = {
  className?: string;
  children: React.ReactNode;
};

export const Tabs: React.FC<TabsProps> = ({ className, children }) => {
  return <div className={`${className}`}>{children}</div>;
};


type TabsListProps = {
  className?: string;
  children: React.ReactNode;
};

export const TabsList: React.FC<TabsListProps> = ({ className, children }) => {
  return <div className={`${className}`}>{children}</div>;
};

type TabsContentProps = {
  className?: string;
  children: React.ReactNode;
};

export const TabsContent: React.FC<TabsContentProps> = ({ className, children }) => {
  return (
    <div className={`${className}`}>
      {children}
    </div>
  );
};
