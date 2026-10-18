import ButtonLink from './ButtonLink'

export default function ProjectCard({ project, ui }) {
  return (
    <article className="overflow-hidden rounded-2xl border border-line bg-surface lg:grid lg:grid-cols-2">
      <img
        src={project.screenshot}
        alt={project.screenshot_alt}
        width="1600"
        height="1000"
        loading="lazy"
        decoding="async"
        className="aspect-[16/10] w-full border-b border-line object-cover object-top lg:h-full lg:border-b-0 lg:border-r"
      />

      <div className="flex flex-col gap-5 p-5 sm:p-8">
        <div>
          <h3 className="text-2xl font-bold tracking-tight">{project.name}</h3>
          <p className="mt-2 text-lg text-muted">{project.description}</p>
        </div>

        <div>
          <h4 className="text-sm font-semibold uppercase tracking-wide text-muted">{ui.features_heading}</h4>
          <ul className="mt-2 space-y-2">
            {project.features.map((feature) => (
              <li key={feature} className="flex gap-3">
                <span aria-hidden="true" className="mt-2.5 size-1.5 shrink-0 rounded-full bg-accent" />
                <span>{feature}</span>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h4 className="sr-only">{ui.stack_heading}</h4>
          <ul className="flex flex-wrap gap-2">
            {project.stack.map((tech) => (
              <li key={tech} className="rounded-full border border-line bg-page px-3 py-1 text-sm text-muted">
                {tech}
              </li>
            ))}
          </ul>
        </div>

        <div className="mt-auto flex flex-wrap gap-3 pt-2">
          {project.live_url && (
            <ButtonLink href={project.live_url} variant="primary" external>{ui.live_button}</ButtonLink>
          )}
          {project.code_url && (
            <ButtonLink href={project.code_url} external>{ui.code_button}</ButtonLink>
          )}
        </div>
      </div>
    </article>
  )
}
