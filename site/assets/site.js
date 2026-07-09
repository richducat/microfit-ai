const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const revealElements = document.querySelectorAll('.reveal');
if ('IntersectionObserver' in window && !reducedMotion) {
  const reveal = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        reveal.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  revealElements.forEach((element, index) => {
    element.style.transitionDelay = `${Math.min(index % 4, 3) * 70}ms`;
    reveal.observe(element);
  });
} else {
  revealElements.forEach((element) => element.classList.add('is-visible'));
}

const tilt = document.querySelector('[data-tilt]');
if (tilt && !reducedMotion && window.matchMedia('(pointer: fine)').matches) {
  const shell = tilt.querySelector('.phone-shell');
  tilt.addEventListener('pointermove', (event) => {
    const rect = tilt.getBoundingClientRect();
    const x = (event.clientX - rect.left) / rect.width - 0.5;
    const y = (event.clientY - rect.top) / rect.height - 0.5;
    shell.style.transform = `rotateY(${x * 8 - 5}deg) rotateX(${y * -6 + 2}deg)`;
  });
  tilt.addEventListener('pointerleave', () => {
    shell.style.transform = 'rotateY(-7deg) rotateX(2deg)';
  });
}
