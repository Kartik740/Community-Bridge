import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import Navbar from './components/common/Navbar';
import Sidebar from './components/common/Sidebar';

import Login from './pages/Login';
import Register from './pages/Register';

import Dashboard from './pages/Dashboard';
import Surveys from './pages/Surveys';
import SurveyBuilder from './pages/SurveyBuilder';
import Responses from './pages/Responses';
import Volunteers from './pages/Volunteers';
import Tasks from './pages/Tasks';

function PrivateRoute({ children }) {
  const { currentUser } = useAuth();
  return currentUser ? children : <Navigate to="/login" />;
}

function MainLayout({ children }) {
  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Navbar />
        <main className="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50 p-6">
          {children}
        </main>
      </div>
    </div>
  );
}

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        
        {/* Protected Routes */}
        <Route path="/" element={<PrivateRoute><MainLayout><Dashboard /></MainLayout></PrivateRoute>} />
        <Route path="/surveys" element={<PrivateRoute><MainLayout><Surveys /></MainLayout></PrivateRoute>} />
        <Route path="/surveys/build" element={<PrivateRoute><MainLayout><SurveyBuilder /></MainLayout></PrivateRoute>} />
        <Route path="/responses" element={<PrivateRoute><MainLayout><Responses /></MainLayout></PrivateRoute>} />
        <Route path="/volunteers" element={<PrivateRoute><MainLayout><Volunteers /></MainLayout></PrivateRoute>} />
        <Route path="/tasks" element={<PrivateRoute><MainLayout><Tasks /></MainLayout></PrivateRoute>} />
      </Routes>
    </Router>
  );
}

export default App;
