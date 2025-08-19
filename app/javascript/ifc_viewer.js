import { IfcViewerAPI } from 'web-ifc-viewer';

window.initIFCViewer = function(containerId, ifcUrl) {
  const container = document.getElementById(containerId);
  if (!container) return;
  container.innerHTML = '';
  const viewer = new IfcViewerAPI({ container, backgroundColor: 0xf8fafc });
  viewer.grid.setGrid();
  viewer.axes.setAxes();
  viewer.IFC.setWasmPath('https://unpkg.com/web-ifc@0.0.46/');
  viewer.IFC.loadIfcUrl(ifcUrl);
};
