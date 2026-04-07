import React, { createContext, useContext, useState, useEffect } from 'react';
import { auth, db } from '../services/firebase';
import { 
  onAuthStateChanged, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut 
} from 'firebase/auth';
import { doc, getDoc, setDoc } from 'firebase/firestore';

const AuthContext = createContext();

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    console.log("AuthContext: useEffect mounting, calling onAuthStateChanged...");
    const timeout = setTimeout(() => {
        console.warn("AuthContext: onAuthStateChanged took too long! Forcing app load.");
        setLoading(false);
    }, 2000);

    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      clearTimeout(timeout);
      console.log("AuthContext: onAuthStateChanged fired. User:", user ? user.uid : "null");
      setCurrentUser(user);
      if (user) {
         try {
             const docRef = doc(db, 'organisations', user.uid);
             const docSnap = await getDoc(docRef);
             if (docSnap.exists()) {
                 console.log("AuthContext: Profile loaded from DB");
                 setUserProfile({ id: user.uid, ...docSnap.data() });
             } else {
                 console.log("AuthContext: Profile not found, using mockup");
                 setUserProfile({ id: user.uid, name: 'Demo Organization', email: user.email });
             }
         } catch(e) {
             console.error("Firestore auth sync failed", e);
             setUserProfile({ id: 'helping-hands', name: 'Helping Hands NGO' });
         }
      } else {
         setUserProfile(null);
      }
      setLoading(false);
    });

    return () => {
        clearTimeout(timeout);
        unsubscribe();
    };
  }, []);

  const login = (email, password) => {
    return signInWithEmailAndPassword(auth, email, password);
  };

  const register = async (email, password, orgName, location) => {
    const res = await createUserWithEmailAndPassword(auth, email, password);
    await setDoc(doc(db, 'organisations', res.user.uid), {
        name: orgName,
        email,
        location,
        createdAt: new Date()
    });
    return res;
  };

  const logout = () => {
    return signOut(auth);
  };

  const value = {
    currentUser,
    userProfile,
    login,
    register,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
}
