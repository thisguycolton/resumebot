export default function Footer({ person, ui }) {
  const linkClass = 'font-medium text-accent underline underline-offset-4 hover:no-underline'

  return (
    <footer className="border-t border-line">
      <div className="mx-auto w-full max-w-5xl px-4 py-12 sm:px-6">
        <h2 className="text-xl font-bold">{ui.footer_heading}</h2>
        <ul className="mt-4 flex flex-col gap-3 sm:flex-row sm:gap-8">
          <li><a className={linkClass} href={person.email_href}>{person.email}</a></li>
          <li><a className={linkClass} href={person.github_url} target="_blank" rel="noopener noreferrer">{ui.github_button}</a></li>
          {person.linkedin_url && (
            <li><a className={linkClass} href={person.linkedin_url} target="_blank" rel="noopener noreferrer">{ui.linkedin_label}</a></li>
          )}
        </ul>
      </div>
    </footer>
  )
}
