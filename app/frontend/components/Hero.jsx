import ButtonLink from './ButtonLink'

export default function Hero({ person, ui }) {
  return (
    <header className="mx-auto w-full max-w-5xl px-4 pb-14 pt-16 sm:px-6 sm:pb-20 sm:pt-24">
      <p className="text-base font-semibold text-accent sm:text-lg">{person.role}</p>
      <h1 className="mt-2 text-4xl font-bold tracking-tight sm:text-6xl">{person.name}</h1>
      <p className="mt-4 text-xl text-ink sm:text-2xl">{person.skills}</p>
      <p className="mt-2 text-lg text-muted">
        {person.location} · {person.availability}
      </p>

      <div className="mt-8 flex flex-wrap gap-3">
        <ButtonLink href={person.email_href} variant="primary">{ui.email_button}</ButtonLink>
        <ButtonLink href={person.resume_path} download={person.resume_filename}>{ui.resume_button}</ButtonLink>
        <ButtonLink href={person.github_url} external>{ui.github_button}</ButtonLink>
      </div>
    </header>
  )
}
