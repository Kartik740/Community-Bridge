import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, doc, setDoc } from 'firebase/firestore';
import { db } from '../services/firebase';
import { useNavigate } from 'react-router-dom';
import { Save, Plus, Trash2, GripVertical, Type, Hash, ChevronDown, ListChecks, Calendar, Image as ImageIcon, Sparkles, ArrowRight, X, LayoutTemplate } from 'lucide-react';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';

const FIELD_TYPES = [
  { type: 'text', label: 'Short Text', icon: Type, color: 'text-blue-500', bg: 'bg-blue-50', hover: 'hover:bg-blue-100', border: 'border-blue-200' },
  { type: 'number', label: 'Number', icon: Hash, color: 'text-emerald-500', bg: 'bg-emerald-50', hover: 'hover:bg-emerald-100', border: 'border-emerald-200' },
  { type: 'dropdown', label: 'Dropdown', icon: ChevronDown, color: 'text-violet-500', bg: 'bg-violet-50', hover: 'hover:bg-violet-100', border: 'border-violet-200' },
  { type: 'multiplechoice', label: 'Multiple Choice', icon: ListChecks, color: 'text-orange-500', bg: 'bg-orange-50', hover: 'hover:bg-orange-100', border: 'border-orange-200' },
  { type: 'date', label: 'Date', icon: Calendar, color: 'text-rose-500', bg: 'bg-rose-50', hover: 'hover:bg-rose-100', border: 'border-rose-200' },
  { type: 'photo', label: 'Photo Upload', icon: ImageIcon, color: 'text-teal-500', bg: 'bg-teal-50', hover: 'hover:bg-teal-100', border: 'border-teal-200' }
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
      label: '',
      type: type,
      required: false,
      options: ['Option 1']
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

  const removeOption = (fieldId, optIndex) => {
    setFields(fields.map(f => {
      if (f.id === fieldId) {
        return { ...f, options: f.options.filter((_, i) => i !== optIndex) };
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
    if(!title.trim()) return alert("Survey Title is required fields to publish.");
    if(fields.length === 0) return alert("Please add at least one field to your survey.");

    setLoading(true);
    try {
      const code = generateSurveyCode();
      const newRef = doc(collection(db, 'surveys'));
      await setDoc(newRef, {
         orgId: userProfile?.id || 'demo-org',
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

  const getFieldTypeConfig = (type) => FIELD_TYPES.find(t => t.type === type) || FIELD_TYPES[0];

  return (
    <div className="max-w-7xl mx-auto pb-24 animate-fade-in space-y-8">
      {/* Header Banner */}
      <div className="relative overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-primary-900 via-primary-800 to-indigo-900 p-8 sm:p-14 shadow-2xl">
        <div className="absolute top-0 right-0 -mt-10 -mr-10 w-96 h-96 bg-white opacity-5 rounded-full blur-3xl pointer-events-none"></div>
        <div className="absolute bottom-0 left-20 w-64 h-64 bg-primary-400 opacity-10 rounded-full blur-3xl pointer-events-none"></div>
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-8">
          <div>
            <div className="inline-flex items-center space-x-2 bg-white/10 backdrop-blur-md px-4 py-1.5 rounded-full text-white/90 text-sm font-semibold mb-6 border border-white/20 shadow-sm">
              <Sparkles className="w-4 h-4 text-primary-300" />
              <span>Beautiful Survey Creator</span>
            </div>
            <h1 className="text-4xl sm:text-5xl font-black text-white tracking-tight mb-4 leading-tight">Build Your Next <br className="hidden sm:block" /> Impactful Survey</h1>
            <p className="text-primary-100 text-lg max-w-xl font-medium">Design dynamic, engaging data collection forms that volunteers actually want to fill out.</p>
          </div>
          <button 
            onClick={handleSave}
            disabled={loading}
            className="group btn-premium flex items-center justify-center space-x-3 px-8 py-5 rounded-2xl whitespace-nowrap self-start md:self-auto bg-white text-primary-900 hover:bg-gray-50 ring-4 ring-white/20 shadow-2xl hover:shadow-primary-900/50 hover:-translate-y-1 transition-all"
          >
            {loading ? (
              <span className="flex items-center text-lg font-bold">
                <svg className="animate-spin -ml-1 mr-3 h-6 w-6 text-primary-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                Publishing...
              </span>
            ) : (
              <>
                <span className="text-lg font-black">Publish Survey</span>
                <ArrowRight className="w-6 h-6 group-hover:translate-x-1.5 transition-transform" />
              </>
            )}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Main Editor Canvas */}
        <div className="lg:col-span-8 xl:col-span-9 space-y-8">
           <div className="glass-panel p-8 sm:p-10 rounded-[2.5rem] space-y-6">
             <div className="relative group">
                <input
                  className="w-full text-4xl sm:text-5xl font-black text-gray-900 border-none outline-none bg-transparent placeholder-gray-300 pb-2 transition-colors border-b-2 border-transparent focus:border-primary-500"
                  placeholder="Survey Title..."
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                />
             </div>
             <div className="relative group pt-4">
                <textarea
                  className="w-full text-xl text-gray-600 border-none outline-none bg-transparent resize-none placeholder-gray-400 min-h-[100px] transition-colors border-b-2 border-transparent focus:border-gray-300 leading-relaxed"
                  placeholder="Describe the purpose of this survey and what the data will be used for..."
                  value={description}
                  onChange={e => setDescription(e.target.value)}
                />
             </div>
           </div>

           <DragDropContext onDragEnd={onDragEnd}>
              <Droppable droppableId="survey-fields">
                 {(provided, snapshot) => (
                    <div 
                      {...provided.droppableProps} 
                      ref={provided.innerRef} 
                      className={`space-y-6 min-h-[300px] rounded-[2.5rem] transition-all duration-500 ${snapshot.isDraggingOver ? 'bg-primary-50/50 p-6 ring-2 ring-primary-300 border-dashed scale-[1.01]' : ''}`}
                    >
                       {fields.length === 0 && !snapshot.isDraggingOver && (
                         <div className="text-center py-24 px-6 rounded-[2.5rem] border-2 border-dashed border-gray-200 bg-white/40 backdrop-blur-md relative overflow-hidden group hover:border-primary-300 hover:bg-primary-50/20 transition-all duration-500">
                            <div className="absolute inset-0 bg-gradient-to-b from-transparent to-gray-50/50 pointer-events-none group-hover:to-primary-50/30 transition-colors"></div>
                            <div className="relative z-10">
                              <div className="w-24 h-24 mx-auto bg-gray-100 rounded-full flex items-center justify-center mb-6 group-hover:bg-primary-100 group-hover:scale-110 transition-all duration-500">
                                <LayoutTemplate className="w-12 h-12 text-gray-400 group-hover:text-primary-500 transition-colors" />
                              </div>
                              <h3 className="text-2xl font-black text-gray-800 mb-3 group-hover:text-primary-900 transition-colors">Build Your Canvas</h3>
                              <p className="text-gray-500 text-lg max-w-md mx-auto group-hover:text-gray-600 transition-colors">Drag and drop fields or click from the sidebar tools to start constructing your survey.</p>
                            </div>
                         </div>
                       )}

                       {fields.map((field, index) => {
                          const TypeIcon = getFieldTypeConfig(field.type).icon;
                          const tColor = getFieldTypeConfig(field.type).color;
                          const tBg = getFieldTypeConfig(field.type).bg;
                          
                          return (
                            <Draggable key={field.id} draggableId={field.id} index={index}>
                               {(provided, snapshot) => (
                                  <div 
                                    ref={provided.innerRef}
                                    {...provided.draggableProps}
                                    className={`relative group bg-white rounded-3xl shadow-sm border border-gray-100 transition-all duration-300 ${snapshot.isDragging ? 'shadow-2xl ring-4 ring-primary-500/30 scale=[1.03] rotate-1' : 'hover:shadow-xl hover:border-gray-200 hover:-translate-y-0.5'}`}
                                  >
                                     <div className="absolute top-0 left-0 w-2.5 h-full bg-gray-100 rounded-l-3xl group-hover:bg-primary-300 transition-colors duration-300"></div>
                                     <div className="p-6 sm:p-8 flex items-start gap-4 sm:gap-6 ml-1">
                                       <div 
                                         {...provided.dragHandleProps}
                                         className="text-gray-300 cursor-grab active:cursor-grabbing flex-shrink-0 mt-2 hover:text-primary-500 transition-colors p-2 -ml-2 rounded-xl hover:bg-primary-50 bg-white"
                                       >
                                          <GripVertical className="w-7 h-7" />
                                       </div>
                                       
                                       <div className="flex-grow space-y-6">
                                          <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                                             <div className="flex-grow">
                                                <input
                                                  className="w-full text-2xl font-bold text-gray-900 bg-transparent outline-none border-b-2 border-transparent focus:border-primary-500 placeholder-gray-300 pb-2 transition-colors"
                                                  placeholder="Type your question here..."
                                                  value={field.label}
                                                  onChange={e => updateField(field.id, 'label', e.target.value)}
                                                />
                                             </div>
                                          </div>

                                          {/* Options Editor */}
                                          {['dropdown', 'multiplechoice'].includes(field.type) && (
                                             <div className="space-y-3 bg-gray-50/50 p-6 rounded-2xl border border-gray-100 shadow-inner">
                                                <p className="text-sm font-bold text-gray-400 uppercase tracking-widest mb-4">Options configuration</p>
                                                {field.options.map((opt, optIndex) => (
                                                   <div key={optIndex} className="flex items-center gap-3 bg-white p-3 rounded-xl shadow-sm border border-gray-100 group/opt focus-within:ring-2 focus-within:ring-primary-100 focus-within:border-primary-300 transition-all duration-300">
                                                      <div className="w-6 h-6 rounded-full border-2 border-gray-200 flex-shrink-0 flex items-center justify-center bg-gray-50">
                                                        {field.type === 'multiplechoice' && <div className="w-2.5 h-2.5 rounded-sm bg-transparent group-hover/opt:bg-gray-300 transition-colors"></div>}
                                                      </div>
                                                      <input
                                                        className="text-base font-semibold text-gray-700 outline-none bg-transparent flex-grow"
                                                        value={opt}
                                                        placeholder={`Option ${optIndex + 1}`}
                                                        onChange={e => updateOption(field.id, optIndex, e.target.value)}
                                                      />
                                                      <button 
                                                        onClick={() => removeOption(field.id, optIndex)}
                                                        className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg opacity-0 group-hover/opt:opacity-100 transition-all"
                                                        title="Remove Option"
                                                      >
                                                        <X className="w-5 h-5" />
                                                      </button>
                                                   </div>
                                                ))}
                                                <button 
                                                  onClick={() => addOption(field.id)} 
                                                  className="inline-flex items-center text-sm text-primary-600 font-bold hover:text-primary-800 hover:bg-primary-100 px-4 py-2.5 rounded-xl transition-colors mt-3 w-full justify-center border border-primary-100 border-dashed"
                                                >
                                                   <Plus className="w-5 h-5 mr-2" /> Add Next Option
                                                </button>
                                             </div>
                                          )}

                                          {/* Bottom Action Bar */}
                                          <div className="flex flex-wrap justify-between items-center bg-gray-50/80 -mx-6 sm:-mx-8 px-6 sm:px-8 py-4 sm:py-5 -mb-6 sm:-mb-8 mt-8 border-t border-gray-100 rounded-b-3xl">
                                             <div className={`flex items-center space-x-2.5 text-sm px-4 py-2 rounded-full border border-gray-200 ${tBg} ${tColor} shadow-sm backdrop-blur-sm`}>
                                                <TypeIcon className="w-4 h-4" />
                                                <span className="font-bold tracking-wide uppercase text-xs">{getFieldTypeConfig(field.type).label}</span>
                                             </div>
                                             <div className="flex space-x-6 items-center">
                                                <label className="flex items-center space-x-3 cursor-pointer group/req hover:bg-gray-200/50 px-3 py-1.5 rounded-xl transition-colors">
                                                   <span className={`text-sm font-bold transition-colors uppercase tracking-wide ${field.required ? 'text-primary-700' : 'text-gray-500'}`}>Required</span>
                                                   <div className="relative flex items-center">
                                                     <input 
                                                       type="checkbox" 
                                                       checked={field.required}
                                                       onChange={e => updateField(field.id, 'required', e.target.checked)}
                                                       className="sr-only"
                                                     />
                                                     <div className={`w-11 h-6 bg-gray-200 rounded-full transition-colors duration-300 shadow-inner ${field.required ? 'bg-primary-500' : ''}`}></div>
                                                     <div className={`absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-300 shadow-sm ${field.required ? 'translate-x-5' : ''}`}></div>
                                                   </div>
                                                </label>
                                                <div className="w-px h-8 bg-gray-200"></div>
                                                <button 
                                                  onClick={() => removeField(field.id)} 
                                                  className="text-gray-400 hover:text-red-600 p-2.5 hover:bg-red-50 rounded-xl transition-all"
                                                  title="Delete Field"
                                                >
                                                   <Trash2 className="w-5 h-5" />
                                                </button>
                                             </div>
                                          </div>
                                       </div>
                                     </div>
                                  </div>
                               )}
                            </Draggable>
                          );
                       })}
                       {provided.placeholder}
                    </div>
                 )}
              </Droppable>
           </DragDropContext>
        </div>

        {/* Tools Sidebar */}
        <div className="lg:col-span-4 xl:col-span-3">
           <div className="glass-panel p-7 rounded-[2.5rem] sticky top-8 shadow-2xl border border-white/60 bg-white/60">
              <div className="flex items-center space-x-3 mb-6 text-gray-900">
                <div className="w-10 h-10 rounded-2xl bg-primary-100 flex items-center justify-center shadow-sm">
                  <Plus className="w-6 h-6 text-primary-600" />
                </div>
                <h3 className="font-black text-xl">Add Element</h3>
              </div>
              <p className="text-sm font-medium text-gray-500 mb-8 leading-relaxed">Click any field below to append it to your survey forms instantly.</p>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-1 gap-3.5">
                 {FIELD_TYPES.map(ft => {
                    const Icon = ft.icon;
                    return (
                      <button
                        key={ft.type}
                        onClick={() => addField(ft.type)}
                        className={`w-full group flex items-center p-4 rounded-2xl border-2 border-transparent bg-white hover:border-primary-200 shadow-sm hover:shadow-lg hover:-translate-y-0.5 transition-all duration-300 text-left relative overflow-hidden`}
                      >
                         <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/50 to-transparent -translate-x-full group-hover:animate-[shimmer_1.5s_infinite] pointer-events-none"></div>
                         <div className={`w-12 h-12 rounded-xl flex items-center justify-center mr-4 transition-all duration-300 ${ft.bg} ${ft.color} group-hover:scale-110 shadow-sm`}>
                            <Icon className="w-6 h-6" />
                         </div>
                         <div>
                           <span className="block text-base font-bold text-gray-800 group-hover:text-gray-900 transition-colors uppercase tracking-wide">{ft.label}</span>
                           <span className="block text-xs font-semibold text-gray-400 mt-0.5 capitalize">{ft.type} Component</span>
                         </div>
                      </button>
                    );
                 })}
              </div>
           </div>
        </div>
      </div>
    </div>
  );
};

export default SurveyBuilder;
