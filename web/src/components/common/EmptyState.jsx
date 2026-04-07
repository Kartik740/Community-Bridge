import React from 'react';
import { FolderOpen } from 'lucide-react';

const EmptyState = ({ title, message, icon: Icon = FolderOpen, action }) => {
  return (
    <div className="flex flex-col items-center justify-center p-12 text-center bg-white border border-dashed rounded-2xl w-full">
      <div className="bg-gray-50 p-4 rounded-full mb-4">
        <Icon className="w-8 h-8 text-gray-400" />
      </div>
      <h3 className="text-lg font-bold text-gray-900 mb-1">{title}</h3>
      <p className="text-sm text-gray-500 mb-6 max-w-sm">{message}</p>
      {action && (
        <div>{action}</div>
      )}
    </div>
  );
};

export default EmptyState;
