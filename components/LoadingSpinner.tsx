import React from "react";

interface LoadingSpinnerProps {
  size?: number; // size in pixels
}

export const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({ size = 40 }) => (
  <div
    className="flex items-center justify-center"
    style={{ width: size, height: size }}
  >
    <div className="animate-spin rounded-full border-b-2 border-gray-500 w-full h-full"></div>
  </div>
);
