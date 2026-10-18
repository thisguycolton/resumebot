import Section from './Section'

function Player({ video }) {
  const { media, title, poster } = video

  if (media.kind === 'file') {
    return (
      <video className="size-full" controls playsInline preload="metadata" poster={poster} title={title}>
        <source src={media.src} type="video/mp4" />
      </video>
    )
  }

  return (
    <iframe
      className="size-full"
      src={media.src}
      title={title}
      loading="lazy"
      allow="fullscreen; picture-in-picture"
      allowFullScreen
      referrerPolicy="strict-origin-when-cross-origin"
    />
  )
}

function Placeholder({ video }) {
  return (
    <div className="flex size-full flex-col items-center justify-center gap-3 p-6 text-center">
      <svg aria-hidden="true" viewBox="0 0 24 24" className="size-12 text-accent" fill="none" stroke="currentColor" strokeWidth="1.5">
        <circle cx="12" cy="12" r="10" />
        <path d="M10 8.5v7l6-3.5-6-3.5Z" fill="currentColor" stroke="none" />
      </svg>
      <p className="text-lg font-semibold">{video.placeholder_title}</p>
      <p className="max-w-sm text-muted">{video.placeholder_text}</p>
    </div>
  )
}

export default function DemoVideo({ video }) {
  return (
    <Section id="demo" heading={video.heading}>
      <div className="aspect-video w-full overflow-hidden rounded-xl border border-line bg-surface">
        {video.media ? <Player video={video} /> : <Placeholder video={video} />}
      </div>
    </Section>
  )
}
