import React from 'react';
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

const NeedsHeatmap = ({ coordinates }) => {
  // Center of Bhopal
  const center = [23.2599, 77.4126];

  if (!coordinates || coordinates.length === 0) {
     return (
        <div className="w-full h-96 rounded-3xl glass-panel flex flex-col items-center justify-center text-slate-400">
           <div className="animate-pulse w-8 h-8 rounded-full bg-slate-200 mb-3"></div>
           <p className="font-medium">Loading geospatial data...</p>
        </div>
     );
  }

  return (
    <div className="w-full h-96 rounded-3xl overflow-hidden glass-panel border border-white/60 shadow-inner relative z-0">
      <MapContainer center={center} zoom={12} style={{ width: '100%', height: '100%', zIndex: 1 }}>
        <TileLayer
          url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
          attribution='&copy; <a href="https://carto.com/">CartoDB</a>'
        />
        {coordinates.map((point, idx) => (
          <CircleMarker
            key={idx}
            center={[point.lat, point.lng]}
            radius={10}
            pathOptions={{ 
                color: '#ef4444', 
                fillColor: '#ef4444', 
                fillOpacity: 0.5, 
                weight: 0 
            }}
          >
            <Popup className="rounded-xl overflow-hidden shadow-xl border-0">
              <div className="p-2 min-w-[200px]">
                <strong className="text-slate-900 block border-b pb-1 mb-2 font-display">Survey Tracker: {point.surveyId}</strong>
                <div className="text-xs text-slate-600 space-y-1.5 font-medium">
                  {point.answers ? point.answers.map((a, i) => (
                      <div key={i} className="flex justify-between">
                         <span className="text-slate-400">{a.fieldId}:</span> 
                         <span className="text-slate-800 text-right max-w-[120px] truncate">{Array.isArray(a.value) ? a.value.join(', ') : a.value}</span>
                      </div>
                  )) : 'No field details available'}
                </div>
              </div>
            </Popup>
          </CircleMarker>
        ))}
      </MapContainer>
    </div>
  );
};

export default NeedsHeatmap;
