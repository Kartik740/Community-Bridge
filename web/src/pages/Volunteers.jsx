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
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-2xl font-black text-gray-900">Volunteers</h1>
          <p className="text-gray-500">Manage your field workers and review applications</p>
        </div>
        <div className="flex rounded-xl overflow-hidden border border-gray-200 bg-white shadow-sm">
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
              <div key={vol.id} className="glass p-6 rounded-2xl transition-all border-t-4 border-t-primary-500">
                <div className="flex justify-between items-start mb-4">
                  <h3 className="text-xl font-bold text-gray-900">{vol.name}</h3>
                  <button
                    onClick={() => toggleAvailability(vol.id, vol.availability)}
                    title="Toggle Availability"
                    className={`flex items-center text-xs font-bold px-2 py-1 rounded-full border ${
                      vol.availability ? 'bg-green-50 text-green-700 border-green-200' : 'bg-red-50 text-red-700 border-red-200'
                    }`}
                  >
                    {vol.availability ? <CheckCircle className="w-3 h-3 mr-1" /> : <XCircle className="w-3 h-3 mr-1" />}
                    {vol.availability ? 'Available' : 'Busy'}
                  </button>
                </div>

                <div className="space-y-3 mb-6 flex-grow text-sm">
                  <div className="flex items-center text-gray-600">
                    <Mail className="w-4 h-4 mr-3 text-gray-400" />
                    {vol.email}
                  </div>
                  <div className="flex items-center text-gray-600">
                    <Phone className="w-4 h-4 mr-3 text-gray-400" />
                    {vol.phone}
                  </div>
                  {vol.location?.lat != null && (
                    <div className="flex items-center text-gray-600">
                      <MapPin className="w-4 h-4 mr-3 text-gray-400" />
                      Last Ping: {vol.location.lat?.toFixed(4)}, {vol.location.lng?.toFixed(4)}
                    </div>
                  )}
                </div>

                <div className="mt-auto border-t pt-4">
                  <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2 flex items-center">
                    <Award className="w-4 h-4 mr-1" />
                    Registered Skills
                  </p>
                  <div className="flex flex-wrap gap-2">
                    {vol.skills?.map(skill => (
                      <span key={skill} className="bg-primary-50 text-primary-600 text-xs font-semibold px-2.5 py-1 rounded-md border border-primary-100 capitalize">
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
              <div key={req.id} className="glass p-6 rounded-2xl">
                <div className="flex justify-between items-start flex-wrap gap-4">
                  {/* Left — Volunteer info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center font-bold text-primary-600 text-sm flex-shrink-0">
                        {req.name?.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <h3 className="font-bold text-gray-900">{req.name}</h3>
                        <p className="text-sm text-gray-500">Age {req.age} · {req.city}</p>
                      </div>
                      <span className="ml-auto flex items-center text-xs text-orange-600 font-semibold bg-orange-50 px-2 py-0.5 rounded-full border border-orange-200">
                        <Clock className="w-3 h-3 mr-1" />
                        Pending
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-x-6 gap-y-1 text-sm text-gray-600 mb-3">
                      <div className="flex items-center"><Mail className="w-3.5 h-3.5 mr-2 text-gray-400" />{req.email}</div>
                      <div className="flex items-center"><Phone className="w-3.5 h-3.5 mr-2 text-gray-400" />{req.phone}</div>
                    </div>

                    <div className="flex flex-wrap gap-2 mb-3">
                      {req.skills?.map(skill => (
                        <span key={skill} className="bg-primary-50 text-primary-600 text-xs font-semibold px-2.5 py-1 rounded-md capitalize">
                          {skill}
                        </span>
                      ))}
                    </div>

                    <div className="flex gap-4 text-xs text-gray-500">
                      <span>⏰ {req.availabilityTime?.replace('_', ' ')}</span>
                      {req.appliedAt?.seconds && (
                        <span>
                          Applied {new Date(req.appliedAt.seconds * 1000).toLocaleDateString()}
                        </span>
                      )}
                    </div>

                    {req.motivation && (
                      <p className="mt-2 text-sm italic text-gray-500 bg-gray-50 rounded-lg px-3 py-2">
                        "{req.motivation}"
                      </p>
                    )}
                  </div>

                  {/* Right — Actions */}
                  <div className="flex flex-col gap-2 flex-shrink-0">
                    <button
                      onClick={() => handleApprove(req)}
                      disabled={actionLoading === req.id}
                      className="flex items-center bg-green-600 hover:bg-green-700 disabled:opacity-50 text-white px-4 py-2 rounded-xl text-sm font-bold transition-colors shadow-sm"
                    >
                      <UserCheck className="w-4 h-4 mr-2" />
                      {actionLoading === req.id ? 'Approving...' : 'Approve'}
                    </button>
                    <button
                      onClick={() => setRejectModal({ requestId: req.id, name: req.name })}
                      disabled={actionLoading === req.id}
                      className="flex items-center bg-red-50 hover:bg-red-100 disabled:opacity-50 text-red-600 border border-red-200 px-4 py-2 rounded-xl text-sm font-bold transition-colors"
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
