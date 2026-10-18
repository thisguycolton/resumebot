const VARIANTS = {
  primary: 'bg-accent text-on-accent border-accent hover:opacity-90',
  secondary: 'bg-transparent text-ink border-line hover:border-accent hover:text-accent',
}

// A link that looks like a button. External links open in a new tab.
export default function ButtonLink({ href, variant = 'secondary', external = false, download, children }) {
  const externalProps = external ? { target: '_blank', rel: 'noopener noreferrer' } : {}

  return (
    <a
      href={href}
      download={download}
      {...externalProps}
      className={`inline-flex min-h-11 items-center justify-center rounded-lg border px-5 py-2.5 text-base font-semibold transition-colors ${VARIANTS[variant]}`}
    >
      {children}
    </a>
  )
}
