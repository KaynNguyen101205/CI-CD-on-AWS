export default function Home() {
  return (
    <main style={{ minHeight: '100vh', display: 'grid', placeItems: 'center', fontFamily: 'sans-serif' }}>
      <section style={{ textAlign: 'center', padding: '2rem' }}>
        <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Jenkins CI/CD Demo</h1>
        <p style={{ fontSize: '1.125rem', maxWidth: '32rem' }}>
          Deploy this Next.js sample through your Jenkins pipeline. Page is lightweight t2.micro can handle it.
        </p>
      </section>
    </main>
  );
}

