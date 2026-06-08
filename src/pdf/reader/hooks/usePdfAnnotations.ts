import { useEffect, useState } from "react";
import { useDocumentCacheStore } from "../stores";

export function usePdfAnnotations(id: string) {
  const annotations = useDocumentCacheStore(s => s.documents[id]?.annotations);
  const fetchAnnotations = useDocumentCacheStore(s => s.fetchAnnotations);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const result = await fetchAnnotations(id);
      if (!result.ok) {
        setError(result.error);
      }
    })();
  }, [id, fetchAnnotations]);

  return {
    annotations: annotations ?? null,
    error: error,
    loading: !annotations,
  };
}