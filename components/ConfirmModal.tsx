import React from "react";

interface ConfirmModalProps {
  title: string;
  description: string;
  onConfirm: () => void;
  onCancel: () => void;
  open: boolean;
}

export const ConfirmModal: React.FC<ConfirmModalProps> = ({
  title,
  description,
  onConfirm,
  onCancel,
  open,
}) => {
  if (!open) return null;
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 backdrop-blur-sm z-50">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg max-w-sm w-full p-6 space-y-4">
        <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100">{title}</h2>
        <p className="text-gray-600 dark:text-gray-300">{description}</p>
        <div className="flex justify-end space-x-3">
          <button
            onClick={onCancel}
            className="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded hover:bg-gray-300 dark:hover:bg-gray-600 transition"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition"
          >
            Confirm
          </button>
        </div>
      </div>
    </div>
  );
};
