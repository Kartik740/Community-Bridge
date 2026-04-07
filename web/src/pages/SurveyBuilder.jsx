import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, doc, setDoc } from 'firebase/firestore';
import { db } from '../services/firebase';
import { useNavigate } from 'react-router-dom';
import { Save, Plus, Trash2, GripVertical } from 'lucide-react';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';

const FIELD_TYPES = [
  { type: 'text', label: 'Short Text' },
  { type: 'number', label: 'Number' },
  { type: 'dropdown', label: 'Dropdown' },
  { type: 'multiplechoice', label: 'Multiple Choice' },
  { type: 'date', label: 'Date' },
  { type: 'photo', label: 'Photo Upload' }
];

const generateSurveyCode = () => Math.random().toString(36).substring(2, 8).toUpperCase();

const SurveyBuilder = () => {
  const { userProfile } = useAuth();
  const navigate = useNavigate();
  
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [fields, setFields] = useState([]);
  const [loading, setLoading] = useState(false);

  const addField = (type) => {
    setFields([...fields, {
      id: Math.random().toString(36).substring(2, 9),
      label: 'New Question',
      type: type,
      required: false,
      options: ['Option 1'] // Default for multiplechoice / dropdown
    }]);
  };

  const updateField = (id, key, value) => {
    setFields(fields.map(f => f.id === id ? { ...f, [key]: value } : f));
  };

  const updateOption = (fieldId, optIndex, value) => {
    setFields(fields.map(f => {
      if (f.id === fieldId) {
        const newOptions = [...f.options];
        newOptions[optIndex] = value;
        return { ...f, options: newOptions };
      }
      return f;
    }));
  };

  const addOption = (fieldId) => {
    setFields(fields.map(f => {
      if (f.id === fieldId) {
        return { ...f, options: [...f.options, `Option ${f.options.length + 1}`] };
      }
      return f;
    }));
  };

  const removeField = (id) => {
    setFields(fields.filter(f => f.id !== id));
  };

  const onDragEnd = (result) => {
    if (!result.destination) return;
    const items = Array.from(fields);
    const [reorderedItem] = items.splice(result.source.index, 1);
    items.splice(result.destination.index, 0, reorderedItem);
    setFields(items);
  };

  const handleSave = async () => {
    if(!title.trim()) return alert("Title is required");
    if(fields.length === 0) return alert("Add at least one field");

    setLoading(true);
    try {
      const code = generateSurveyCode();
      const newRef = doc(collection(db, 'surveys'));
      await setDoc(newRef, {
         orgId: userProfile.id,
         title,
         description,
         surveyCode: code,
         fields,
         createdAt: new Date(),
         isActive: true
      });
      navigate('/surveys');
    } catch (err) {
       console.error("Save failed", err);
       alert("Failed to save survey");
    } finally {
       setLoading(false);
    }
  };

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div className="flex justify-between items-center mb-6">
        <div>
           <h1 className="text-2xl font-black text-gray-900">Survey Builder</h1>
           <p className="text-gray-500">Design dynamic fields for volunteer data collection</p>
        </div>
        <button 
          onClick={handleSave}
          disabled={loading}
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-xl font-bold flex items-center shadow-sm disabled:opacity-50 transition-all"
        >
          <Save className="w-5 h-5 mr-2" />
          {loading ? 'Saving...' : 'Save & Publish'}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        <div className="md:col-span-3 space-y-6">
           <div className="glass p-6 rounded-2xl space-y-4">
             <input
               className="w-full text-2xl font-bold text-gray-900 border-none outline-none bg-transparent placeholder-gray-300"
               placeholder="Survey Title..."
               value={title}
               onChange={e => setTitle(e.target.value)}
             />
             <textarea
               className="w-full text-sm text-gray-600 border-none outline-none bg-transparent resize-none placeholder-gray-300"
               placeholder="Description of the survey goal..."
               value={description}
               onChange={e => setDescription(e.target.value)}
             />
           </div>

           <DragDropContext onDragEnd={onDragEnd}>
              <Droppable droppableId="survey-fields">
                 {(provided) => (
                    <div {...provided.droppableProps} ref={provided.innerRef} className="space-y-6">
                       {fields.map((field, index) => (
                          <Draggable key={field.id} draggableId={field.id} index={index}>
                             {(provided) => (
                                <div 
                                  ref={provided.innerRef}
                                  {...provided.draggableProps}
                                  className="glass p-6 rounded-2xl relative group flex space-x-4 bg-white shadow-sm"
                                >
                                   <div 
                                     {...provided.dragHandleProps}
                                     className="text-gray-300 cursor-grab flex-shrink-0 mt-2 hover:text-gray-500 transition-colors"
                                   >
                                      <GripVertical className="w-6 h-6" />
                                   </div>
                                   <div className="flex-grow space-y-4">
                                      <div className="flex justify-between">
                                         <input
                                           className="w-full text-lg font-bold text-gray-900 bg-transparent outline-none border-b focus:border-primary-500 pb-1"
                                           value={field.label}
                                           onChange={e => updateField(field.id, 'label', e.target.value)}
                                         />
                                      </div>
                                      {(field.type === 'dropdown' || field.type === 'multiplechoice') && (
                                         <div className="space-y-2 pl-2 border-l-2 border-gray-100">
                                            {field.options.map((opt, optIndex) => (
                                               <div key={optIndex} className="flex items-center space-x-2">
                                                  <div className="w-4 h-4 rounded-full border border-gray-300 flex-shrink-0"></div>
                                                  <input
                                                    className="text-sm outline-none border-b focus:border-gray-500 bg-transparent flex-grow"
                                                    value={opt}
                                                    onChange={e => updateOption(field.id, optIndex, e.target.value)}
                                                  />
                                               </div>
                                            ))}
                                            <button onClick={() => addOption(field.id)} className="text-sm text-primary-600 font-medium pt-2 pl-6">
                                               + Add option
                                            </button>
                                         </div>
                                      )}
                                      <div className="flex justify-between items-center border-t pt-4 mt-6">
                                         <div className="flex items-center space-x-2 text-sm text-gray-500 bg-gray-50 px-3 py-1 rounded-md">
                                            <span className="font-medium capitalize">{field.type}</span>
                                         </div>
                                         <div className="flex space-x-4 items-center">
                                            <label className="flex items-center space-x-2 text-sm text-gray-700">
                                               <input 
                                                 type="checkbox" 
                                                 checked={field.required}
                                                 onChange={e => updateField(field.id, 'required', e.target.checked)}
                                                 className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                                               />
                                               <span>Required</span>
                                            </label>
                                            <button onClick={() => removeField(field.id)} className="text-gray-400 hover:text-red-500 transition-colors">
                                               <Trash2 className="w-5 h-5" />
                                            </button>
                                         </div>
                                      </div>
                                   </div>
                                </div>
                             )}
                          </Draggable>
                       ))}
                       {provided.placeholder}
                    </div>
                 )}
              </Droppable>
           </DragDropContext>
        </div>

        <div className="space-y-4">
           <div className="glass p-6 rounded-2xl sticky top-6">
              <h3 className="font-bold text-gray-900 mb-4">Add Field</h3>
              <div className="space-y-2">
                 {FIELD_TYPES.map(ft => (
                    <button
                      key={ft.type}
                      onClick={() => addField(ft.type)}
                      className="w-full text-left flex items-center p-3 rounded-xl border border-transparent hover:border-gray-200 hover:bg-gray-50 transition-colors"
                    >
                       <Plus className="w-4 h-4 mr-3 text-primary-500" />
                       <span className="text-sm font-medium text-gray-700">{ft.label}</span>
                    </button>
                 ))}
              </div>
           </div>
        </div>
      </div>
    </div>
  );
};

export default SurveyBuilder;
