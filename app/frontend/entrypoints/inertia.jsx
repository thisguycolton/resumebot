import { createInertiaApp } from '@inertiajs/react'

void createInertiaApp({
  pages: '../pages',
  strictMode: true,
}).catch((error) => {
  // Only Inertia pages load this entrypoint, so a missing root element is a setup mistake.
  if (document.getElementById('app')) {
    throw error
  } else {
    console.error('Missing #app root element: this entrypoint should only load on Inertia pages.')
  }
})
