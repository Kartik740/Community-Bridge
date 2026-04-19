import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
  collection, query, where, getDocs, doc,
  updateDoc, setDoc, serverTimestamp
} from 'firebase/firestore';
import { db } from '../services/firebase';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { MapPin, Phone, Mail, Award, CheckCircle, XCircle, Clock, UserCheck, UserX } from 'lucide-react';
import toast, { Toaster } from 'react-hot-toast';

const Volunteers = () => {
  const { userProfile } = useAuth();
  const [activeTab, setActiveTab] = useState('volunteers'); // 'volunteers' | 'requests'
  const [volunteers, setVolunteers] = useState([]);
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);

  // Reject modal state
  const [rejectModal, setRejectModal] = useState(null); // { requestId, name }
  const [rejectReason, setRejectReason] = useState('');
  const [actionLoading, setActionLoading] = useState(null); // requestId being acted on

  useEffect(() => {
    if (userProfile?.id) {
      fetchAll();
    }
  }, [userProfile]);

  const fetchAll = async () => {
    setLoading(true);
    try {
      const [volSnap, reqSnap] = await Promise.all([
        getDocs(query(collection(db, 'volunteers'), where('orgId', '==', userProfile.id))),
        getDocs(query(collection(db, 'volunteerRequests'), where('orgId', '==', userProfile.id), where('status', '==', 'pending'))),
      ]);
      setVolunteers(volSnap.docs.map(d => ({ id: d.id, ...d.data() })));
      setRequests(reqSnap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      console.error(err);
      toast.error('Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const toggleAvailability = async (id, currentStatus) => {
    try {
      await updateDoc(doc(db, 'volunteers', id), { availability: !currentStatus });
      setVolunteers(volunteers.map(v => v.id === id ? { ...v, availability: !currentStatus } : v));
    } catch (err) {
      toast.error('Failed to update availability');
    }
  };

  // ── Approve ──────────────────────────────────────────────────────────────

  const handleApprove = async (request) => {
    setActionLoading(request.id);
    try {
      // 1. Update request status
      await updateDoc(doc(db, 'volunteerRequests', request.id), {
        status: 'approved',
        reviewedAt: serverTimestamp(),
      });

      // 2. Create volunteer document using the same UID as requestId
      await setDoc(doc(db, 'volunteers', request.id), {
        name: request.name,
        age: request.age,
        city: request.city,
        email: request.email,
        phone: request.phone,
        orgId: request.orgId,
        orgName: request.orgName,
        skills: request.skills || [],
        availabilityTime: request.availabilityTime || '',
        availability: true,
        location: { lat: 0, lng: 0 },
        fcmToken: '',
        createdAt: serverTimestamp(),
      });

      // Remove from requests list, add to volunteers list
      setRequests(prev => prev.filter(r => r.id !== request.id));
      setVolunteers(prev => [
        ...prev,
        {
          id: request.id,
          ...request,
          availability: true,
          skills: request.skills || [],
        },
      ]);

      toast.success(`${request.name} approved and added as volunteer!`);
    } catch (err) {
      console.error(err);
      toast.error('Approval failed. Please try again.');
    } finally {
      setActionLoading(null);
    }
  };

  // ── Reject ───────────────────────────────────────────────────────────────

  const handleReject = async () => {
    if (!rejectModal) return;
    if (!rejectReason.trim()) {
      toast.error('Please enter a rejection reason');
      return;
    }

    setActionLoading(rejectModal.requestId);
    try {
      await updateDoc(doc(db, 'volunteerRequests', rejectModal.requestId), {
        status: 'rejected',
        rejectionReason: rejectReason.trim(),
        reviewedAt: serverTimestamp(),
      });
      setRequests(prev => prev.filter(r => r.id !== rejectModal.requestId));
      setRejectModal(null);
      setRejectReason('');
      toast.success('Application rejected.');
    } catch (err) {
      toast.error('Rejection failed. Please try again.');
    } finally {
      setActionLoading(null);
    }
  };

  if (loading) return <LoadingSpinner message="Loading volunteers..." />;

  return (
    <div className="space-y-6">
      <Toaster position="top-right" />

      {/* Header + Tabs */}
      <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
        <div>
          <h1 className="text-2xl font-black text-gray-900">Volunteers</h1>
          <p className="text-gray-500">Manage your field workers and review applications</p>
        </div>
        <div className="flex rounded-xl overflow-hidden border border-gray-200 bg-white shadow-sm w-full sm:w-auto">
          <button
            onClick={() => setActiveTab('volunteers')}
            className={`px-5 py-2.5 text-sm font-semibold transition-colors ${
              activeTab === 'volunteers'
                ? 'bg-primary-600 text-white'
                : 'text-gray-500 hover:bg-gray-50'
            }`}
          >
            Active ({volunteers.length})
          </button>
          <button
            onClick={() => setActiveTab('requests')}
            className={`px-5 py-2.5 text-sm font-semibold transition-colors relative ${
              activeTab === 'requests'
                ? 'bg-primary-600 text-white'
                : 'text-gray-500 hover:bg-gray-50'
            }`}
          >
            Requests
            {requests.length > 0 && (
              <span className="ml-2 bg-orange-500 text-white text-xs font-bold px-1.5 py-0.5 rounded-full">
                {requests.length}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* ── ACTIVE VOLUNTEERS TAB ── */}
      {activeTab === 'volunteers' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {volunteers.length === 0 ? (
            <div className="col-span-full text-center py-12 glass rounded-2xl">
              <p className="text-gray-500">No approved volunteers yet. Review requests to add them.</p>
            </div>
          ) : (
            volunteers.map(vol => (
              <div key={vol.id} className="bg-white rounded-3xl p-6 border border-gray-100/80 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] hover:shadow-[0_12px_36px_-6px_rgba(0,0,0,0.1)] transition-all duration-300 flex flex-col group relative overflow-hidden backdrop-blur-xl">
                 {/* Top accent line */}
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary-400 to-indigo-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                
                <div className="flex justify-between items-start mb-6">
                  <div className="flex gap-4 items-center">
                    <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary-50 to-indigo-50 flex items-center justify-center font-bold text-xl text-primary-600 ring-1 ring-primary-500/20 shadow-inner">
                      {vol.name?.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <h3 className="text-lg font-bold text-gray-900 leading-tight group-hover:text-primary-600 transition-colors">{vol.name}</h3>
                      <button
                        onClick={() => toggleAvailability(vol.id, vol.availability)}
                        title="Toggle Availability"
                        className={`mt-1.5 flex items-center text-[10px] uppercase tracking-wider font-extrabold px-2.5 py-1 rounded-lg border transition-all ${
                          vol.availability 
                            ? 'bg-emerald-50 text-emerald-600 border-emerald-200/60 hover:bg-emerald-100' 
                            : 'bg-rose-50 text-rose-600 border-rose-200/60 hover:bg-rose-100'
                        }`}
                      >
                        {vol.availability ? <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5 animate-pulse" /> : <span className="w-1.5 h-1.5 rounded-full bg-rose-500 mr-1.5" />}
                        {vol.availability ? 'Available' : 'Busy'}
                      </button>
                    </div>
                  </div>
                </div>

                <div className="space-y-3.5 mb-8 flex-grow text-sm">
                  <div className="flex items-center text-gray-600 group/item">
                    <div className="w-8 h-8 rounded-xl bg-gray-50 flex items-center justify-center mr-3 group-hover/item:bg-primary-50 transition-colors">
                      <Mail className="w-4 h-4 text-gray-400 group-hover/item:text-primary-500 transition-colors" />
                    </div>
                    <span className="truncate">{vol.email}</span>
                  </div>
                  <div className="flex items-center text-gray-600 group/item">
                    <div className="w-8 h-8 rounded-xl bg-gray-50 flex items-center justify-center mr-3 group-hover/item:bg-primary-50 transition-colors">
                      <Phone className="w-4 h-4 text-gray-400 group-hover/item:text-primary-500 transition-colors" />
                    </div>
                    <span>{vol.phone}</span>
                  </div>
                  {vol.location?.lat != null && (
                    <div className="flex items-center text-gray-600 group/item">
                      <div className="w-8 h-8 rounded-xl bg-gray-50 flex items-center justify-center mr-3 group-hover/item:bg-primary-50 transition-colors">
                        <MapPin className="w-4 h-4 text-gray-400 group-hover/item:text-primary-500 transition-colors" />
                      </div>
                      <span className="truncate">Ping: {vol.location.lat?.toFixed(4)}, {vol.location.lng?.toFixed(4)}</span>
                    </div>
                  )}
                </div>

                <div className="mt-auto pt-5 border-t border-gray-100/80">
                  <div className="flex items-center justify-between mb-3">
                    <p className="text-[11px] font-bold text-gray-400 uppercase tracking-widest flex items-center">
                      <Award className="w-3.5 h-3.5 mr-1.5" />
                      Skills
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {vol.skills?.map(skill => (
                      <span key={skill} className="bg-gray-50 hover:bg-primary-50 hover:text-primary-600 text-gray-600 text-xs font-semibold px-3 py-1.5 rounded-lg border border-gray-200/60 hover:border-primary-200 transition-all cursor-default capitalize shadow-sm">
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* ── REQUESTS TAB ── */}
      {activeTab === 'requests' && (
        <div className="space-y-4">
          {requests.length === 0 ? (
            <div className="text-center py-16 glass rounded-2xl">
              <CheckCircle className="w-10 h-10 text-green-400 mx-auto mb-3" />
              <h3 className="font-bold text-gray-900 text-lg">All caught up!</h3>
              <p className="text-gray-500 mt-1">No pending volunteer applications at the moment.</p>
            </div>
          ) : (
            requests.map(req => (
              <div key={req.id} className="bg-white p-6 rounded-3xl border border-gray-100/80 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.04)] hover:shadow-[0_8px_30px_-6px_rgba(0,0,0,0.08)] transition-all duration-300">
                <div className="flex justify-between items-start flex-wrap gap-6">
                  {/* Left — Volunteer info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-4 mb-5">
                      <div className="w-12 h-12 bg-gradient-to-br from-orange-50 to-amber-50 rounded-2xl flex items-center justify-center font-bold text-orange-600 text-lg shadow-inner ring-1 ring-orange-500/20">
                        {req.name?.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <h3 className="text-lg font-bold text-gray-900 leading-tight">{req.name}</h3>
                        <p className="text-sm text-gray-500 font-medium mt-0.5">Age {req.age} • {req.city}</p>
                      </div>
                      <div className="ml-auto flex items-center text-xs text-orange-600 font-bold bg-orange-50 px-3 py-1.5 rounded-xl border border-orange-200/60 shadow-sm">
                        <Clock className="w-3.5 h-3.5 mr-1.5 animate-pulse" />
                        Pending Review
                      </div>
                    </div>

                    <div className="flex gap-x-8 gap-y-3 mb-5 text-sm">
                      <div className="flex items-center text-gray-600">
                         <div className="w-7 h-7 rounded-lg bg-gray-50 flex items-center justify-center mr-2"><Mail className="w-3.5 h-3.5 text-gray-400" /></div>
                         {req.email}
                      </div>
                      <div className="flex items-center text-gray-600">
                         <div className="w-7 h-7 rounded-lg bg-gray-50 flex items-center justify-center mr-2"><Phone className="w-3.5 h-3.5 text-gray-400" /></div>
                         {req.phone}
                      </div>
                    </div>

                    <div className="space-y-4">
                      <div>
                        <p className="text-[11px] font-bold text-gray-400 uppercase tracking-widest mb-2 flex items-center">
                          <Award className="w-3.5 h-3.5 mr-1.5" />
                          Skills
                        </p>
                        <div className="flex flex-wrap gap-2">
                          {req.skills?.map(skill => (
                            <span key={skill} className="bg-gray-50 text-gray-600 text-xs font-semibold px-3 py-1.5 rounded-lg border border-gray-200/60 capitalize shadow-sm">
                              {skill}
                            </span>
                          ))}
                        </div>
                      </div>

                      {req.motivation && (
                        <div className="bg-gradient-to-r from-gray-50 to-transparent p-4 rounded-2xl border-l-2 border-primary-400 mt-2">
                          <p className="text-sm italic text-gray-600">
                            "{req.motivation}"
                          </p>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Right — Actions */}
                  <div className="flex flex-col gap-3 flex-shrink-0 min-w-[140px] pt-1">
                    <div className="text-[11px] text-center text-gray-400 mb-1 font-semibold uppercase tracking-wider">
                      {req.appliedAt?.seconds ? (
                         <>Applied {new Date(req.appliedAt.seconds * 1000).toLocaleDateString()}</>
                      ) : (
                         <>New Application</>
                      )}
                    </div>
                    <button
                      onClick={() => handleApprove(req)}
                      disabled={actionLoading === req.id}
                      className="w-full flex items-center justify-center bg-gradient-to-r from-emerald-500 to-green-600 hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 text-white px-4 py-2.5 rounded-xl text-sm font-bold transition-all shadow-[0_4px_12px_rgba(16,185,129,0.2)] hover:shadow-[0_6px_16px_rgba(16,185,129,0.3)]"
                    >
                      <UserCheck className="w-4 h-4 mr-2" />
                      {actionLoading === req.id ? 'Approving...' : 'Approve'}
                    </button>
                    <button
                      onClick={() => setRejectModal({ requestId: req.id, name: req.name })}
                      disabled={actionLoading === req.id}
                      className="w-full flex items-center justify-center bg-white hover:bg-rose-50 disabled:opacity-50 text-rose-600 border border-rose-200 px-4 py-2.5 rounded-xl text-sm font-bold transition-all shadow-sm hover:border-rose-300"
                    >
                      <UserX className="w-4 h-4 mr-2" />
                      Reject
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* ── REJECT MODAL ── */}
      {rejectModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl">
            <h3 className="text-lg font-bold text-gray-900 mb-1">Reject Application</h3>
            <p className="text-sm text-gray-500 mb-4">
              Rejecting <strong>{rejectModal.name}</strong>'s application. Please provide a reason.
            </p>
            <textarea
              className="w-full border border-gray-200 rounded-xl p-3 text-sm resize-none focus:outline-none focus:border-primary-400 transition-colors"
              rows={3}
              placeholder="e.g. We currently don't have openings in your city..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              autoFocus
            />
            <div className="flex gap-3 mt-4">
              <button
                onClick={() => { setRejectModal(null); setRejectReason(''); }}
                className="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl font-semibold text-sm hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleReject}
                disabled={actionLoading === rejectModal.requestId}
                className="flex-1 bg-red-600 hover:bg-red-700 disabled:opacity-50 text-white py-2.5 rounded-xl font-bold text-sm transition-colors"
              >
                {actionLoading === rejectModal.requestId ? 'Rejecting...' : 'Confirm Reject'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Volunteers;
