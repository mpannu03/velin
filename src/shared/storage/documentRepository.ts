import { DocumentMeta } from "../types";
import { documentStore } from "./store";

type DocumentMap = Record<string, DocumentMeta>;

const MAX_RECENTS = 10;

class DocumentRepository {
    private documents: DocumentMap = {};

    async init() {
        this.documents = await documentStore.get("documents") ?? {};
    }

    getAll(): DocumentMeta[] {
        return Object.values(this.documents);
    }

    getById(id: string): DocumentMeta | undefined {
        return this.documents[id];
    }

    async save() {
        await documentStore.set("documents", this.documents);
    }

    async add(doc: DocumentMeta) {
        this.documents[doc.id] = doc;
        if (Object.values(this.documents).filter((doc) => !doc.starred).length > MAX_RECENTS) {
            const sorted = Object.values(this.documents).sort(
                (a, b) => b.lastOpened.getTime() - a.lastOpened.getTime()
            );
            this.documents = sorted.slice(0, MAX_RECENTS).reduce((acc, doc) => {
                acc[doc.id] = doc;
                return acc;
            }, {} as DocumentMap);
        }
        await this.save();
    }

    async update(doc: DocumentMeta) {
        this.documents[doc.id] = doc;
        await this.save();
    }

    async delete(id: string) {
        delete this.documents[id];
        await this.save();
    }
}

export const documentRepository = new DocumentRepository();