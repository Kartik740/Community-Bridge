import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, query, where, getDocs, doc, updateDoc } from 'firebase/firestore';
import { db } from '../services/firebase';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { Check, Clock, Edit3, X, ShieldCheck, ListChecks } from 'lucide-react';
import toast, { Toaster } from 'react-hot-toast';

const Responses = () => {
  const { userProfile } = useAuth();
  const [responses, setResponses] = useState([]);
  const [filter, setFilter] = useState('All');
  const [loading, setLoading] = useState(true);
  const [selectedIds, setSelectedIds] = useState([]);

  // Inline view state
  const [selectedResponse, setSelectedResponse] = useState(null);

  useEffect(() => {
    fetchResponses();
  }, [userProfile]);

  const fetchResponses = async () => {
    if (!userProfile?.id) return;
    try {
      const withTimeout = (promise, ms) => Promise.race([promise, new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), ms))]);
      const q = query(collection(db, 'responses'), where('orgId', '==', userProfile.id));
      
      const snap = await withTimeout(getDocs(q), 3000);
      setResponses(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      console.warn('Firebase query timed out. Displaying fallback UI data.', err);
      // Fallback Data
      setResponses([
         { id: '1', status: 'pending', surveyId: 'SURV-FOOD-001', volunteerId: 'John Doe', submittedAt: new Date(), location: { lat: 23.2599, lng: 77.4126 }, answers: [{fieldId: 'Headcount', value: '120'}] },
         { id: '2', status: 'approved', surveyId: 'SURV-MED-002', volunteerId: 'Alice Smith', submittedAt: new Date(), location: { lat: 23.2699, lng: 77.4226 }, answers: [{fieldId: 'Urgency', value: 'High'}] }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const filteredResponses = responses.filter(r => filter === 'All' ? true : r.status.toLowerCase() === filter.toLowerCase());

  const handleApprove = async (id) => {
    try {
      await updateDoc(doc(db, 'responses', id), { 
         status: 'approved',
         answers: selectedResponse?.id === id ? selectedResponse.answers : responses.find(r=>r.id===id).answers
      });
      setResponses(responses.map(r => r.id === id ? { ...r, status: 'approved', answers: selectedResponse?.id === id ? selectedResponse.answers : r.answers } : r));
      if (selectedResponse?.id === id) {
          setSelectedResponse({ ...selectedResponse, status: 'approved' });
      }
      toast.success('Response approved!');
    } catch (err) {
      toast.error('Error approving response');
    }
  };

  const handleBulkApprove = async () => {
    if (selectedIds.length === 0) return;
    try {
      await Promise.all(selectedIds.map(id => updateDoc(doc(db, 'responses', id), { status: 'approved' })));
      setResponses(responses.map(r => selectedIds.includes(r.id) ? { ...r, status: 'approved' } : r));
      setSelectedIds([]);
      toast.success(`Bulk approved ${selectedIds.length} responses!`);
    } catch (err) {
      toast.error('Error in bulk approval');
    }
  };

  const handleSelect = (id) => {
     setSelectedIds(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]);
  };
  
  const handleSelectAll = () => {
     if (selectedIds.length === filteredResponses.length) {
        setSelectedIds([]);
     } else {
        setSelectedIds(filteredResponses.map(r => r.id));
     }
  };

  const handleAnswerEdit = (fieldId, newValue) => {
    if (!selectedResponse) return;
    setSelectedResponse(prev => ({
       ...prev,
       answers: prev.answers.map(ans => ans.fieldId === fieldId ? { ...ans, value: newValue } : ans)
    }));
  };

  if (loading) return <LoadingSpinner message="Loading responses..." />;

  return (
    <div className="flex h-full gap-6">
      <Toaster position="top-right" />
      <div className={`flex-grow space-y-6 transition-all ${selectedResponse ? 'w-2/3' : 'w-full'}`}>
        <div className="flex justify-between items-center mb-10">
          <div>
            <h1 className="text-3xl font-display font-black text-slate-900 tracking-tight">Survey Responses</h1>
            <p className="text-slate-500 font-medium mt-1 tracking-wide">Review and verify field data</p>
          </div>
          <div className="flex items-center space-x-4">
             {selectedIds.length > 0 && (
                <button 
                   onClick={handleBulkApprove}
                   className="flex items-center bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-xl text-sm font-bold transition-colors shadow-sm"
                >
                   <ListChecks className="w-4 h-4 mr-2" />
                   Approve Selected ({selectedIds.length})
                </button>
             )}
             <div className="flex space-x-2 bg-white rounded-xl p-1 shadow-sm border border-gray-100">
                {['All', 'Pending', 'Approved', 'Analysed'].map(f => (
               <button 
                 key={f}
                 onClick={() => setFilter(f)}
                 className={`px-4 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                   filter === f ? 'bg-primary-50 text-primary-600 shadow-sm' : 'text-gray-500 hover:text-gray-900'
                 }`}
               >
                 {f}
               </button>
             ))}
            </div>
          </div>
        </div>

        <div className="glass-panel overflow-hidden rounded-3xl">
          <table className="w-full text-left text-sm text-slate-500">
            <thead className="bg-slate-50/50 text-slate-700 uppercase text-xs font-bold border-b border-slate-200 backdrop-blur-md">
              <tr>
                <th className="px-6 py-4 w-10">
                   <input 
                      type="checkbox" 
                      onChange={handleSelectAll}
                      checked={filteredResponses.length > 0 && selectedIds.length === filteredResponses.length}
                   />
                </th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Survey ID</th>
                <th className="px-6 py-4">Volunteer</th>
                <th className="px-6 py-4">Submitted</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredResponses.length === 0 ? (
                 <tr>
                    <td colSpan="6" className="px-6 py-12 text-center text-slate-500 font-medium">No responses match filter.</td>
                 </tr>
              ) : (
                filteredResponses.map(r => (
                  <tr key={r.id} className={`border-b border-slate-100 hover:bg-slate-50/80 transition-all cursor-pointer ${selectedResponse?.id === r.id ? 'bg-primary-50/50' : ''}`} onClick={() => setSelectedResponse(r)}>
                    <td className="px-6 py-4" onClick={e => e.stopPropagation()}>
                       <input 
                          type="checkbox" 
                          checked={selectedIds.includes(r.id)}
                          onChange={() => handleSelect(r.id)}
                       />
                    </td>
                    <td className="px-6 py-4">
                       <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold ${
                          r.status === 'approved' || r.status === 'analysed' ? 'bg-green-100 text-green-800' : 'bg-orange-100 text-orange-800'
                       }`}>
                          {r.status === 'approved' || r.status === 'analysed' ? <Check className="w-3 h-3 mr-1" /> : <Clock className="w-3 h-3 mr-1" />}
                          {r.status}
                       </span>
                    </td>
                    <td className="px-6 py-4 font-mono font-medium text-gray-900">{r.surveyId}</td>
                    <td className="px-6 py-4 font-medium max-w-[150px] truncate">{r.volunteerId}</td>
                    <td className="px-6 py-4">{r.submittedAt?.toDate ? r.submittedAt.toDate().toLocaleDateString() : new Date(r.submittedAt).toLocaleDateString()}</td>
                    <td className="px-6 py-4 text-right">
                       <button onClick={(e) => { e.stopPropagation(); setSelectedResponse(r); }} className="text-primary-600 hover:bg-primary-100 p-2 rounded-lg transition-colors">
                          <Edit3 className="w-4 h-4" />
                       </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Slide-over panel for review */}
      {selectedResponse && (
        <div className="w-1/3 bg-white border-l shadow-2xl h-full flex flex-col fixed right-0 top-0 pt-16 z-20 overflow-hidden slide-in-from-right-full">
           <div className="p-6 border-b flex justify-between items-center bg-gray-50">
              <h3 className="font-bold text-lg text-gray-900">Review Response</h3>
              <button onClick={() => setSelectedResponse(null)} className="text-gray-400 hover:text-gray-900 transition-colors">
                 <X className="w-6 h-6" />
              </button>
           </div>
           
           <div className="flex-grow overflow-y-auto p-6 space-y-6">
              <div className="grid grid-cols-2 gap-4 text-sm bg-gray-50 p-4 rounded-xl">
                 <div>
                    <p className="text-gray-500 font-medium">Synced</p>
                    <p className="font-bold text-gray-900">{selectedResponse.syncedAt?.toDate ? selectedResponse.syncedAt.toDate().toLocaleTimeString() : new Date(selectedResponse.syncedAt).toLocaleTimeString()}</p>
                 </div>
                 <div>
                    <p className="text-gray-500 font-medium">Location</p>
                    <p className="font-bold font-mono text-gray-900">
                        {selectedResponse.location?.lat.toFixed(4)}, {selectedResponse.location?.lng.toFixed(4)}
                    </p>
                 </div>
              </div>

              <div>
                 <h4 className="font-bold text-gray-900 mb-4 border-b pb-2">Submitted Answers</h4>
                 <div className="space-y-4">
                    {selectedResponse.answers?.map((ans, idx) => (
                       <div key={idx} className="bg-white border p-3 rounded-xl shadow-sm">
                          <p className="text-xs font-bold text-primary-600 uppercase mb-1 flex items-center">
                             Field ID: {ans.fieldId}
                          </p>
                          <input 
                             className="w-full mt-1 p-2 border rounded text-gray-900 focus:border-primary-500 outline-none transition-colors"
                             value={Array.isArray(ans.value) ? ans.value.join(', ') : ans.value}
                             onChange={(e) => handleAnswerEdit(ans.fieldId, e.target.value)}
                             disabled={selectedResponse.status !== 'pending'}
                          />
                       </div>
                    ))}
                 </div>
              </div>
           </div>
           
           <div className="p-6 border-t bg-gray-50">
              {selectedResponse.status === 'pending' ? (
                  <button 
                    onClick={() => handleApprove(selectedResponse.id)}
                    className="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-3 rounded-xl shadow-sm flex justify-center items-center transition-colors"
                  >
                     <ShieldCheck className="w-5 h-5 mr-2" />
                     Save & Approve
                  </button>
              ) : (
                  <div className="w-full bg-gray-200 text-gray-600 font-bold py-3 rounded-xl text-center flex justify-center items-center">
                     <Check className="w-5 h-5 mr-2" />
                     Already {selectedResponse.status}
                  </div>
              )}
           </div>
        </div>
      )}
    </div>
  );
};

export default Responses;
