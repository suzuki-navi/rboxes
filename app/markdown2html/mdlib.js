mermaid.initialize({
    startOnLoad: false,
    logLevel: 'info',
});
document.addEventListener('DOMContentLoaded', async () => {
    document.querySelectorAll('code.language-mermaid').forEach(code => {
        const container = document.createElement('div');
        container.className = 'mermaid';
        container.textContent = code.textContent; // プレーンテキスト化
        code.replaceWith(container);
    });
    try {
        await mermaid.run({ querySelector: '.mermaid' });
    } catch (err) {
        console.error('Mermaid run() failed:', err);
    }
});

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('content');
    const elements = document.querySelectorAll('.mermaid');
    const zoomables = []
    for (const element of elements) {
        zoomables.push(element.parentElement);
    }
    for (const zoomable of zoomables) {
        zoomable.style.overflow = "hidden";
        zoomable.style.cursor = "grab";
        zoomable.style.padding = "0";

        const contentDiv = document.createElement('div');
        contentDiv.style.width = "100%";
        contentDiv.style.height = "100%";
        contentDiv.style.transformOrigin = "0 0";
        while (zoomable.firstChild) {
            contentDiv.appendChild(zoomable.firstChild);
        }
        zoomable.appendChild(contentDiv);

        const zoomableHeight = zoomable.clientHeight;
        const screenHeight = window.innerHeight;

        let scale = 1;
        let originX = 0;
        let originY = 0;
        let startX = 0;
        let startY = 0;
        let isDragging = false;

        zoomable.addEventListener('wheel', (event) => {
            event.preventDefault();
            const zoomFactor = 1.1;
            const rect = zoomable.getBoundingClientRect();
            const offsetX = event.clientX - rect.left;
            const offsetY = event.clientY - rect.top;
            const zoom = event.deltaY > 0 ? 1 / zoomFactor : 1 * zoomFactor;

            const newScale = scale * zoom;
            const newOriginX = offsetX - (offsetX - originX) / scale * newScale;
            const newOriginY = offsetY - (offsetY - originY) / scale * newScale;

            scale = newScale;
            originX = newOriginX;
            originY = newOriginY;

            updateTransform();
        });
        zoomable.addEventListener('mousedown', (event) => {
            event.preventDefault();
            startX = event.clientX - originX;
            startY = event.clientY - originY;
            isDragging = true;
        });

        document.addEventListener('mousemove', (event) => {
            if (isDragging) {
                originX = event.clientX - startX;
                originY = event.clientY - startY;
                updateTransform();
            }
        });

        document.addEventListener('mouseup', () => {
            isDragging = false;
        });

        let oldScale = scale;
        let oldZoomableHeight = zoomableHeight;
        function updateTransform() {
            const newZoomableHeight = (() => {
                if (scale <= 1.0) {
                    return zoomableHeight;
                }
                return Math.min(zoomableHeight * scale, screenHeight * 0.8);
            })();

            const deltaY = (newZoomableHeight - oldZoomableHeight) / 2;
            originY += deltaY;

            zoomable.style.height = `${newZoomableHeight}px`;
            contentDiv.style.transform = `translate(${originX}px, ${originY}px) scale(${scale})`;
            container.scrollTop += deltaY;

            oldScale = scale;
            oldZoomableHeight = newZoomableHeight;
        }
    }
});
