// A titled block with consistent spacing and width.
export default function Section({ id, heading, children }) {
  return (
    <section id={id} aria-labelledby={`${id}-heading`} className="mx-auto w-full max-w-5xl px-4 py-12 sm:px-6 sm:py-16">
      <h2 id={`${id}-heading`} className="mb-6 text-2xl font-bold tracking-tight sm:text-3xl">
        {heading}
      </h2>
      {children}
    </section>
  )
}
