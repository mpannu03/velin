import { DocumentMeta, DocumentPatch } from "../types";
import { documentStore } from "./store";

type DocumentMap = Record<string, DocumentMeta>;

class DocumentRepository {
	private documents: DocumentMap = {};

	async init() {
		const data = await documentStore.get<DocumentMap>("documents") ?? {};
		// Convert strings to Dates
		this.documents = Object.entries(data).reduce((acc, [key, doc]) => {
			acc[key] = {
				...doc,
				lastOpened: new Date(doc.lastOpened).getTime()
			};
			return acc;
		}, {} as DocumentMap);
	}

	getAll(): DocumentMeta[] {
		return Object.values(this.documents);
	}

	getByFilePath(filePath: string): DocumentMeta | undefined {
		return this.documents[filePath];
	}

	async save() {
		await documentStore.set("documents", this.documents);
		documentStore.save();
	}

	async add(doc: DocumentMeta) {
		this.documents[doc.filePath] = doc;		
		await this.save();
	}

	async update(patch: DocumentPatch) {
		const { filePath, ...rest } = patch;
		if (!filePath) return;
		
		if (this.documents[filePath]) {
			this.documents[filePath] = {
				...this.documents[filePath],
				...rest
			};
			await this.save();
		}
	}

	async delete(filePath: string) {
		delete this.documents[filePath];
		await this.save();
	}
}

export const documentRepository = new DocumentRepository();