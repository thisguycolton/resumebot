import DemoVideo from '../components/DemoVideo'
import Footer from '../components/Footer'
import Hero from '../components/Hero'
import ProjectCard from '../components/ProjectCard'
import Section from '../components/Section'

export default function Home({ ui, person, video, projects_heading, projects, about }) {
  return (
    <>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:absolute focus:left-4 focus:top-4 focus:z-10 focus:rounded-lg focus:bg-accent focus:px-4 focus:py-2 focus:text-on-accent"
      >
        {ui.skip_to_content}
      </a>

      <Hero person={person} ui={ui} />

      <main id="main">
        <DemoVideo video={video} />

        <Section id="projects" heading={projects_heading}>
          <div className="flex flex-col gap-8">
            {projects.map((project) => (
              <ProjectCard key={project.slug} project={project} ui={ui} />
            ))}
          </div>
        </Section>

        <Section id="about" heading={about.heading}>
          <p className="max-w-3xl text-lg leading-relaxed">{about.body}</p>
        </Section>
      </main>

      <Footer person={person} ui={ui} />
    </>
  )
}
