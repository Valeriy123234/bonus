window.addEventListener('load', () => {
    setTimeout(() => {
        const loader = document.getElementById('loader');
        const content = document.getElementById('main-content');
        
        loader.style.transition = 'opacity 1s ease'; // додаємо плавність через JS для надійності
        loader.style.opacity = '0';
        
        setTimeout(() => {
            loader.style.display = 'none';
            content.classList.remove('hidden');
            content.classList.add('visible');
        }, 1000); 
    }, 3000); // 3 секунди показуємо завантаження + 1 секунда на зникнення = разом 4 сек
});

function navTo(url) {
    // Знаходимо картку для ефекту зникнення
    const card = document.querySelector('.glass-card');
    
    if (card) {
        card.style.transition = '0.6s cubic-bezier(0.4, 0, 0.2, 1)';
        card.style.opacity = '0';
        card.style.transform = 'scale(0.9) translateY(-30px)';
        card.style.filter = 'blur(10px)';
    }

    // Робимо фон тіла теж напівпрозорим для м'якості
    document.body.style.transition = 'opacity 0.6s';
    document.body.style.opacity = '0';

    setTimeout(() => { 
        window.location.href = url; 
    }, 600);
}
