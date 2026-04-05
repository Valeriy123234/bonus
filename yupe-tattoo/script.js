window.addEventListener('load', () => {
    setTimeout(() => {
        const loader = document.getElementById('loader');
        const content = document.getElementById('main-content');
        
        loader.style.opacity = '0';
        setTimeout(() => {
            loader.style.display = 'none';
            content.classList.remove('hidden');
            content.classList.add('visible');
        }, 1000); // час для плавного зникнення
    }, 3000); 
});

function navTo(url) {
    document.body.style.transition = '0.5s';
    document.body.style.opacity = '0';
    setTimeout(() => { window.location.href = url; }, 500);
}
